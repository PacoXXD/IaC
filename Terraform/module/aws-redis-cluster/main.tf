resource "aws_elasticache_subnet_group" "ec_sg_redis" {
  count = "${var.redis_endpoint == "" ? 1 : 0}"

  name       = "${var.name}"
  subnet_ids = ["${var.subnet_ids}"]
}

module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.10.0"

  name        = "${format("%s-redis", var.name)}"
  description = "Security group for redis"
  vpc_id      = "${var.vpc_id}"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "redis-tcp"
      source_security_group_id = "${var.allowed_sg_ids[0]}"
      description              = "Redis"
    },
    {
      rule                     = "redis-tcp"
      source_security_group_id = "${var.allowed_sg_ids[1]}"
      description              = "Redis"
    },
  ]

  number_of_computed_ingress_with_source_security_group_id = 2

  computed_ingress_with_cidr_blocks = [
    {
      rule        = "redis-tcp"
      cidr_blocks = "${var.allowed_cidr}"
      description = "Redis"
    },
  ]

  number_of_computed_ingress_with_cidr_blocks = "${var.allowed_cidr == "" ? 0 : 1}"

  egress_rules = ["all-all"]

  # ingress_with_self = [{
  #   rule        = "all-all"
  #   description = "All protocols"
  # }]
}

resource "aws_elasticache_replication_group" "redis_cluster" {
  count = "${var.redis_endpoint == "" ? 1 : 0}"

  replication_group_id          = "${var.name}"
  replication_group_description = "Redis cluster for backend"

  node_type            = "${var.instance_type}"
  port                 = 6379
  parameter_group_name = "default.redis5.0.cluster.on"

  subnet_group_name  = "${aws_elasticache_subnet_group.ec_sg_redis.name}"
  security_group_ids = ["${module.sg.this_security_group_id}"]

  automatic_failover_enabled = true

  cluster_mode {
    replicas_per_node_group = "${var.num_replica}"
    num_node_groups         = "${var.node_groups}"
  }
}

resource "aws_route53_record" "redis_cluster" {
  # count = "${var.zone_id != "" ? 1 : 0}"

  zone_id = "${var.zone_id}"
  name    = "redis-${var.name_no_env}.${var.domain}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${var.redis_endpoint == "" ? "${element(concat(aws_elasticache_replication_group.redis_cluster.*.configuration_endpoint_address, list("")), 0)}" : "${var.redis_endpoint}"}"]
}
