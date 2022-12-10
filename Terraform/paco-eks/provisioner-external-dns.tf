locals {
  ex_dns_external_sa_name = "aws-external-dns-external"
  ex_dns_internal_sa_name = "aws-external-dns-internal"
  external_dns_namespace  = "external-dns"
}

resource "aws_iam_policy" "AWSExternalDNSIAMPolicy" {
  policy = file("./iam-policy/AWSExternalDNSIAMPolicy.json") # Current Alb charts version is 1.4.4
  name   = "AWSpacoExternalDNSIAMPolicy"
  tags   = merge(local.tags, {
    ChartsVersion = "v6.8.0",
    ChartsName    = "bitnami/external-dns"
  })
}

module "iam_eks_external_dns_role" {
  source           = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name        = "${local.env}-external-dns-paco"
  role_policy_arns = {
    AWSExternalDNSIAMPolicy = aws_iam_policy.AWSExternalDNSIAMPolicy.arn
  }

  oidc_providers = {
    one = {
      provider_arn               = module.prd-paco-eks.oidc_provider_arn
      namespace_service_accounts = [
        "${local.external_dns_namespace}:${local.ex_dns_external_sa_name}",
        "${local.external_dns_namespace}:${local.ex_dns_internal_sa_name}"
      ]
    }
  }

  tags = merge(local.tags, {
    ChartsVersion = "v6.8.0",
    ChartsName    = "bitnami/external-dns"
  })
}

resource "kubernetes_service_account" "external_dns_external_sa" {
  metadata {
    name        = local.ex_dns_external_sa_name
    namespace   = local.external_dns_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_eks_external_dns_role.iam_role_arn
    }
  }
}


resource "kubernetes_service_account" "external_dns_internal_sa" {
  metadata {
    name        = local.ex_dns_internal_sa_name
    namespace   = local.external_dns_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_eks_external_dns_role.iam_role_arn
    }
  }
}