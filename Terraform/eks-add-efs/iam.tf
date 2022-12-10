#resource "aws_iam_role" "aws_load_balancer_controller" {
#  assume_role_policy = file("./iam-policy/AmazonEKS_EFS_CSI_Driver_Policy.json")
#  name               = "aws-load-balancer-controller"
#}

data "aws_iam_policy" "AmazonEKS_EFS_CSI_Driver_Policy" {
#  policy = file("./iam-policy/AmazonEKS_EFS_CSI_Driver_Policy.json")
  name   = "AmazonEKS_EFS_CSI_Driver_Policy"
}

#resource "aws_iam_role_policy_attachment" "amazoneks_efs_csi_driver_policy_attach" {
#  role       = aws_iam_role.aws_load_balancer_controller.name
#  policy_arn = aws_iam_policy.AmazonEKS_EFS_CSI_Driver_Policy.arn
#}


#data.aws_eks_cluster.identity.oidc.issuer
#output "aws_load_balancer_controller_role_arn" {
#  value = aws_iam_role.aws_load_balancer_controller.arn
#}

#module "vpc_cni_irsa_role" {
#  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#
#  role_name = "efs-csi-controller-sa"
#
#  attach_vpc_cni_policy = true
#  vpc_cni_enable_ipv4   = true
#
#  oidc_providers = {
#    main = {
#      provider_arn               = data.aws_eks_cluster.identity.oidc.issuer
#      namespace_service_accounts = ["default:my-app", "canary:my-app"]
#    }
#  }
#}