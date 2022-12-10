data "aws_security_group" "loghub-prd" {
  id = var.sg_id
}

data "aws_region" "current" {
  name = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_opensearch_domain" "example" {
  domain_name    = var.es_domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = 5
    zone_awareness_enabled = true
    zone_awareness_config {
      availability_zone_count = 3
    }
  }

  vpc_options {
    subnet_ids = var.subnet_ids

    security_group_ids = [data.aws_security_group.loghub-prd.id]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }
  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.es_domain_name}/*"
        }
    ]
}
CONFIG

  ebs_options {
    ebs_enabled = true
    volume_size = 500
  }

  tags = {
    Domain = "${var.env}-${var.v_tag}-${var.es_domain_name}"
  }


}