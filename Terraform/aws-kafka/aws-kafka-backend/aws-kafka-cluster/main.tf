locals {
  env            = var.env
  v_tag          = var.v_tag
  msk_name       = format("%s-msk-%s-%s", local.env,var.name,local.v_tag)
  vpc_id         = var.vpc_id
  instance_type  = var.instance_type
  client_subnets = var.client_subnets
  s3_prefix      = format("logs/%s-msk-%s", local.env, local.v_tag)

  tags = {
    Terraform : true,
    Environment : local.env,
    Version : local.v_tag,
  }

}


resource "aws_cloudwatch_log_group" "msk_broker_logs" {
  name = "msk_broker_logs"
}

resource "aws_s3_bucket" "msk_logs" {
  bucket = "stg-msk-backend-bucket"
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.msk_logs.id
  acl    = "private"
}

module "sg" {
  source = "terraform-aws-modules/security-group/aws"
  # version = "4.13.1"

  name        = format("%s-msk-%s", var.env, var.name)
  description = "Security group for msk"
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "kafka-broker-tcp"
      source_security_group_id = "${var.allowed_sg_ids[0]}"
      description              = "msk serverless"
    },
    {
      rule                     = "kafka-broker-tcp"
      source_security_group_id = "${var.allowed_sg_ids[1]}"
      description              = "msk serverless"
    },
    {
      rule                     = "zookeeper-2181-tcp"
      source_security_group_id = "${var.allowed_sg_ids[2]}"
      description              = "msk serverless"
    },
    {
      rule                     = "zookeeper-2181-tcp"
      source_security_group_id = "${var.allowed_sg_ids[3]}"
      description              = "msk serverless"
    },
    # {
    #   rule                     = "mysql-tcp"
    #   source_security_group_id = "${element(var.allowed_sg_ids, 2)}"
    #   description              = "MySQL/Aurora"
    # },
  ]

  # at least 2 for worker and bastion. 1 more for prd monitor
  number_of_computed_ingress_with_source_security_group_id = length(var.allowed_sg_ids)

  egress_rules = ["all-all"]

  # ingress_with_self = [{
  #   rule        = "all-all"
  #   description = "All protocols"
  # }]
}

resource "aws_kms_key" "msk" {
  description = "kms for msk"
}

resource "aws_msk_configuration" "msk_configuration" {
  kafka_versions = ["3.2.0"]
  name           = "msk-configuration"

  server_properties = <<PROPERTIES
    auto.create.topics.enable=true
    default.replication.factor=3
    min.insync.replicas=2
    num.io.threads=8
    num.network.threads=5
    num.partitions=1
    num.replica.fetchers=2
    replica.lag.time.max.ms=30000
    socket.receive.buffer.bytes=102400
    socket.request.max.bytes=104857600
    socket.send.buffer.bytes=102400
    unclean.leader.election.enable=true
    zookeeper.session.timeout.ms=18000
    log.roll.ms=86400000
    log.retention.hours=168
    log.segment.bytes = 1073741824
  PROPERTIES
}


resource "aws_msk_cluster" "stg-msk-v0812" {
  cluster_name           = local.msk_name
  kafka_version          = "3.2.0"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type  = local.instance_type
    client_subnets = local.client_subnets
    storage_info {
      ebs_storage_info {
        volume_size = 20
      }
    }
    security_groups = ["${module.sg.security_group_id}"]
  }

  client_authentication {
    unauthenticated = true
  }

  configuration_info {
    arn      = aws_msk_configuration.msk_configuration.arn
    revision = aws_msk_configuration.msk_configuration.latest_revision
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.msk.arn
    encryption_in_transit {
      client_broker = "TLS_PLAINTEXT"
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.msk_broker_logs.name
      }

      s3 {
        enabled = true
        bucket  = aws_s3_bucket.msk_logs.id
        prefix  = local.s3_prefix
      }
    }
  }
  tags = local.tags
}

