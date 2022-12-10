locals {
  version = "v1018"
  env     = "prd"
  oidc_provider_arn ="arn:aws:iam::726332586568:oidc-provider/oidc.eks.eu-west-1.amazonaws.com/id/AA8D1AA81527FDD5A36D909052D953EF"
  tags    = {
    Environment = local.env
    Terraform   = true
    Version     = local.version
  }
  cluster_autoscaler_sa_name = "aws-cluster-autoscaler"
  cluster_autoscaler_namespace  = "kube-system"
}

data "aws_eks_cluster" "prd-app" {
  name = "prd-app"
}


resource "aws_iam_policy" "AWSClusterAutoscalerIAMPolicy" {
  policy = file("./iam-policy/AWSClusterAutoscalerIAMPolicy.json") 
  name   = "prdAWSClusterAutoscalerIAMPolicy"
  tags   = merge(local.tags, {
    ChartsVersion = "v9.21.0",
    ChartsName    = "cluster-autoscaler/cluster-autoscaler"
  })
}

# module "iam_eks_cluster_autoscaler_role" {
#   source           = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   role_name        = "${local.env}-cluster-autoscaler-stream"
#   role_policy_arns = {
  
#     AWSClusterAutoscalerIAMPolicy = aws_iam_policy.AWSClusterAutoscalerIAMPolicy.arn
#   }

#   oidc_providers = {
#     one = {
#       provider_arn               = local.oidc_provider_arn
#       namespace_service_accounts = [
#         "${local.cluster_autoscaler_namespace}:${local.cluster_autoscaler_sa_name}",
#       ]
#     }
#   }

#   tags   = merge(local.tags, {
#     ChartsVersion = "v9.21.0",
#     ChartsName    = "cluster-autoscaler/cluster-autoscaler"
#   })
# }

# resource "kubernetes_service_account" "cluster_autoscaler_sa" {
#   metadata {
#     name        = local.cluster_autoscaler_sa_name
#     namespace   = local.cluster_autoscaler_namespace
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.iam_eks_cluster_autoscaler_role.iam_role_arn
#     }
#   }
# }
