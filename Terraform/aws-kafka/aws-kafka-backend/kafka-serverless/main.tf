locals {
  env            = var.env
  v_tag          = var.v_tag

  tags = {
    Terraform : true,
    Environment : local.env,
    Version : local.v_tag,
  }

}

module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  # version = "4.13.1"

  name        = "${format("%s-serverless-msk", var.name)}"
  description = "Security group for msk"
  vpc_id      = "${var.vpc_id}"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "kafka-broker-sasl-iam-tcp"
      source_security_group_id = "${var.allowed_sg_ids[0]}"
      description              = "msk serverless"
    },
    {
      rule                     = "kafka-broker-sasl-iam-tcp"
      source_security_group_id = "${var.allowed_sg_ids[1]}"
      description              = "msk serverless"
    },
    # {
    #   rule                     = "mysql-tcp"
    #   source_security_group_id = "${element(var.allowed_sg_ids, 2)}"
    #   description              = "MySQL/Aurora"
    # },
  ]

  # at least 2 for worker and bastion. 1 more for prd monitor
  number_of_computed_ingress_with_source_security_group_id = "${length(var.allowed_sg_ids)}"
  
  egress_rules = ["all-all"]

  # ingress_with_self = [{
  #   rule        = "all-all"
  #   description = "All protocols"
  # }]
}


# Create MSK serverless cluster
resource "aws_msk_serverless_cluster" "msk" {
  cluster_name = format("%s-%s-mskserverless",local.env, var.name)

  vpc_config {
    subnet_ids         = var.client_subnets
    security_group_ids = ["${module.sg.security_group_id}"]
  }

  client_authentication {
    sasl {
      iam {
        enabled = true
      }
    }
  }
  tags = local.tags
}

