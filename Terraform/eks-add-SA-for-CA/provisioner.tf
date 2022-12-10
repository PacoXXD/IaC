resource "null_resource" "create_eks_efs_role" {
  provisioner "local-exec" {
    command = <<-EOF
eksctl create iamserviceaccount \
--cluster ${data.aws_eks_cluster.prd-app.name} \
--namespace ${local.cluster_autoscaler_namespace} \
--name  ${local.cluster_autoscaler_sa_name} \
--attach-policy-arn ${aws_iam_policy.AWSClusterAutoscalerIAMPolicy.arn} \
--approve \
--region eu-west-1
EOF
  }
  depends_on = [
    aws_iam_policy.AWSClusterAutoscalerIAMPolicy
  ]
}

