locals {
  aws_region    = var.aws_region
  key_name      = lookup(var.key_name, var.aws_region)
  ami           = lookup(var.amis, var.aws_region)
  instance_type = lookup(var.instance_type, var.aws_region)


  tags = {
    Terraform   = "true"
    Environment = var.env
    Version     = var.v_tag
  }
}

provider "aws" {
  region = local.aws_region
}

resource "aws_instance" "mainnet" {
  # count = var.instance_num  
  ami           = local.ami
  instance_type = local.instance_type
  vpc_security_group_ids = [
    module.sg.security_group_id
  ]
  key_name                    = local.key_name
  associate_public_ip_address = true
  subnet_id                   = lookup(var.public_subnet_id, var.aws_region)

  root_block_device {
    volume_size = "200"
  }

  tags = merge({
    Name = "${local.env}-mainnet"
  }, local.tags)
}

# Security Group
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  create = true

  name        = "${var.v_tag}-mainnet-EC2-sg"
  description = "Security group for mainnet EC2"
  vpc_id      = lookup(var.vpc_id, var.aws_region)



  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.my_ip
      # cidr_blocks = "0.0.0.0/0"
      description = "SSH"
    },
    {
      from_port   = 26657
      to_port     = 26657
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "mainnet RPC"
    },
    {
      from_port   = 1317
      to_port     = 1317
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "mainnet REST API"
    }

  ]

  egress_rules = [
    "all-all"
  ]

  tags = merge({
    Name = "${local.env}-mainnet"
  }, local.tags)
}



