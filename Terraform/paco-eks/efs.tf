data "aws_vpc" "stream_vpc" {
  id = local.eks_b_vpc_id
}