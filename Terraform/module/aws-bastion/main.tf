data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"

  vars {
    aws_region  = "${var.region}"
    bucket_name = "${var.bucket_name}"
  }
}

locals {
  record_name = "${var.subdomain}.${var.domain}"
}

# resource "aws_s3_bucket" "bucket" {
#   bucket = "${var.bucket_name}"
#   acl    = "bucket-owner-full-control"

#   versioning {
#     enabled = "${var.bucket_versioning}"
#   }

#   lifecycle_rule {
#     id      = "log"
#     enabled = "${var.log_auto_clean}"

#     prefix = "logs/"

#     tags {
#       "rule"      = "log"
#       "autoclean" = "${var.log_auto_clean}"
#     }

#     transition {
#       days          = "${var.log_standard_ia_days}"
#       storage_class = "STANDARD_IA"
#     }

#     transition {
#       days          = "${var.log_glacier_days}"
#       storage_class = "GLACIER"
#     }

#     expiration {
#       days = "${var.log_expiry_days}"
#     }
#   }
# }

module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "2.10.0"

  name        = "${var.name}"
  description = "Security group for bastion"
  vpc_id      = "${var.vpc_id}"

  computed_ingress_with_cidr_blocks = [
    {
      rule        = "ssh-tcp"
      cidr_blocks = "${var.allowed_cidr}"
      description = "SSH"
    },
  ]

  number_of_computed_ingress_with_cidr_blocks = 1

  egress_rules = ["all-all"]

  # ingress_with_self = [{
  #   rule        = "all-all"
  #   description = "All protocols"
  # }]
}

resource "aws_iam_role" "bastion_host_role" {
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Action": [
        "sts:AssumeRole"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "bastion_host_role_policy" {
  role = "${aws_iam_role.bastion_host_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ],
      "Resource": "arn:aws:s3:::${var.bucket_name}/logs/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::${var.bucket_name}/public-keys/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.bucket_name}",
      "Condition": {
        "StringEquals": {
          "s3:prefix": "public-keys/"
        }
      }
    }
  ]
}
EOF
}

resource "aws_route53_record" "bastion_record_name" {
  # count = "${var.route53_enabled}"

  name    = "${local.record_name}"
  zone_id = "${var.zone_id}"

  type = "A"

  alias {
    name                   = "${aws_lb.bastion_lb.dns_name}"
    zone_id                = "${aws_lb.bastion_lb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_lb" "bastion_lb" {
  internal = "${var.lb_internal}"

  subnets = [
    "${var.subnet_ids}",
  ]

  load_balancer_type = "network"
}

resource "aws_lb_target_group" "bastion_lb_target_group" {
  port        = "22"
  protocol    = "TCP"
  vpc_id      = "${var.vpc_id}"
  target_type = "instance"

  health_check {
    port     = "traffic-port"
    protocol = "TCP"
  }
}

resource "aws_lb_listener" "bastion_lb_listener_22" {
  default_action {
    target_group_arn = "${aws_lb_target_group.bastion_lb_target_group.arn}"
    type             = "forward"
  }

  load_balancer_arn = "${aws_lb.bastion_lb.arn}"
  port              = "22"
  protocol          = "TCP"
}

resource "aws_iam_instance_profile" "bastion_host_profile" {
  role = "${aws_iam_role.bastion_host_role.name}"
  path = "/"
}

resource "aws_launch_configuration" "bastion_launch_configuration" {
  image_id                    = "${lookup(var.bastion_amis, var.region)}"
  instance_type               = "${var.instance_type}"
  associate_public_ip_address = true
  enable_monitoring           = true
  iam_instance_profile        = "${aws_iam_instance_profile.bastion_host_profile.name}"
  key_name                    = "${var.bastion_key_pair}"
  name_prefix                 = "${var.name}"

  security_groups = [
    "${module.sg.this_security_group_id}",
  ]

  # TODO: not using user_data for now, since the current user_data doesn't allow scp and ftp
  # user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion_auto_scaling_group" {
  launch_configuration = "${aws_launch_configuration.bastion_launch_configuration.name}"
  max_size             = "${var.bastion_instance_count}"
  min_size             = "${var.bastion_instance_count}"
  desired_capacity     = "${var.bastion_instance_count}"
  name                 = "${var.name}"

  vpc_zone_identifier = [
    "${var.subnet_ids}",
  ]

  default_cooldown          = 180
  health_check_grace_period = 180
  health_check_type         = "EC2"

  target_group_arns = [
    "${aws_lb_target_group.bastion_lb_target_group.arn}",
  ]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.name}"
    propagate_at_launch = true
  }
}
