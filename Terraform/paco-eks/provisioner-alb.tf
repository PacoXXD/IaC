locals {
  alb_sa_name    = "aws-load-balancer-controller"
  alb_install_ns = "kube-system"
  eks_region     = "eu-central-1"
}

module "iam_eks_alb_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "${local.env}-aws-load-balancer-controller-paco"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    one = {
      provider_arn               = module.prd-paco-eks.oidc_provider_arn
      namespace_service_accounts = [
        "${local.alb_install_ns}:${local.alb_sa_name}"
      ]
    }
  }

  tags = merge(local.tags, {
    ChartsVersion = "v1.4.4",
    ChartsName    = "aws/aws-load-balancer-controller"
  })
}

resource "kubernetes_service_account" "alb_sa" {
  metadata {
    name        = local.alb_sa_name
    namespace   = local.alb_install_ns
    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_eks_alb_role.iam_role_arn
    }
  }
}