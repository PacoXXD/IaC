resource "aws_efs_file_system" "eks_fs" {
  creation_token = "${local.env}-eks"

  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true

  # lifecycle_policy {
  #   transition_to_ia = "AFTER_30_DAYS"
  # }

  tags = merge(local.tags, {
    Name = "${local.env}eks-fs"
  })
}

resource "aws_efs_mount_target" "prd_private_zone_efs_mount" {
  for_each        = toset(local.prd_private_subnets_id)
  file_system_id  = aws_efs_file_system.eks_fs.id
  subnet_id       = each.value
  security_groups = [data.aws_eks_cluster.prd-app.vpc_config[0].cluster_security_group_id]
}

resource "aws_security_group_rule" "nfs_sg_rule" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.prd-app.cidr_block]
  security_group_id = data.aws_eks_cluster.prd-app.vpc_config[0].cluster_security_group_id
}