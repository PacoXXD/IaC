module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  # version = "4.9.0"

  name        = "${format("%s-mks", var.name)}"
  description = "Security group for mks"
  vpc_id      = "${var.vpc_id}"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "kafka-broker-sasl-iam-tcp"
      source_security_group_id = "${var.allowed_sg_ids[0]}"
      description              = "mks serverless"
    },
    # {
    #   rule                     = "mks-tcp"
    #   source_security_group_id = "${var.allowed_sg_ids[1]}"
    #   description              = "mks serverless"
    # },
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
resource "aws_msk_serverless_cluster" "example" {
  cluster_name = "${var.msk_name}"

  vpc_config {
    subnet_ids         = "${var.subnet_ids}"
    security_group_ids = ["${module.sg.security_group_id}"]
  }

  client_authentication {
    sasl {
      iam {
        enabled = true
      }
    }
  }

}

