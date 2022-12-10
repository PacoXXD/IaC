resource "null_resource" "create_eks_efs_role" {
  provisioner "local-exec" {
    command = <<-EOF
eksctl create iamserviceaccount \
--cluster ${data.aws_eks_cluster.prd-app.name} \
--namespace kube-system \
--name efs-csi-controller-sa \
--attach-policy-arn ${data.aws_iam_policy.AmazonEKS_EFS_CSI_Driver_Policy.arn} \
--approve \
--region eu-west-1
EOF
  }
  depends_on = [
    data.aws_iam_policy.AmazonEKS_EFS_CSI_Driver_Policy
  ]
}