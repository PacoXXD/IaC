# https://medium.com/aws-activate-startup-blog/practical-vpc-design-8412e1a18dcc
locals {
  az_count = 3
  az_cidrs = [cidrsubnet(var.cidr, 2, 0), cidrsubnet(var.cidr, 2, 1), cidrsubnet(var.cidr, 2, 2)]
}

data "aws_availability_zones" "available" {}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  #  version = "1.71.0" //always uses the latest

  create_vpc            = var.create
  name                  = var.name
  cidr                  = var.cidr
  secondary_cidr_blocks = var.secondary_cidr_blocks

  azs             = slice(data.aws_availability_zones.available.names, 0, local.az_count)
  private_subnets = [cidrsubnet(local.az_cidrs[0], 1, 0), cidrsubnet(local.az_cidrs[1], 1, 0), cidrsubnet(local.az_cidrs[2], 1, 0)]
  public_subnets  = [cidrsubnet(local.az_cidrs[0], 1, 1), cidrsubnet(local.az_cidrs[1], 1, 1), cidrsubnet(local.az_cidrs[2], 1, 1)]

  create_database_subnet_group = false

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway
//  reuse_nat_ips = true

  tags = {
    Name = var.name
    terraform = "true"
  }

  vpc_tags             = var.vpc_tags
  private_subnet_tags  = var.subnet_private_tags
  public_subnet_tags   = var.subnet_public_tags
  enable_dns_hostnames = true
}
