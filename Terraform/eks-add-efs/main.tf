locals {
  version = "v0815"
  env     = "paco"
  tags    = {
    Environment = local.env
    Terraform   = true
    Version     = local.version
  }
  paco_vpc_id = "vpc-0b50c0f0ee4cf13ba"

  paco_private_subnets_id = [
    "subnet-06ec337f23c593802",
    "subnet-0125e9cbbf9daa41e",
    "subnet-020bf002c59c806cf",
  ]
}

data "aws_vpc" "paco-app" {
  id = local.paco_vpc_id
}

data "aws_eks_cluster" "paco-app" {
  name = "paco-app"
}


