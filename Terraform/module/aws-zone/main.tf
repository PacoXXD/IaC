resource "aws_route53_zone" "zone" {
  count         = "${1 - var.private_enabled}"
  name          = "${var.domain_name}"
  comment       = "${var.comment}"
  force_destroy = false
}

resource "aws_route53_zone" "zone_private" {
  count         = "${var.private_enabled}"
  name          = "${var.domain_name}"
  comment       = "${var.comment}"
  force_destroy = false

  vpc {
    vpc_id = "${var.vpc_id}"
  }

  # To work with additional vpc association
  # https://www.terraform.io/docs/providers/aws/r/route53_zone.html#private-zone
  lifecycle {
    ignore_changes = ["vpc"]
  }
}

data "aws_route53_zone" "zone_root" {
  name = "${var.domain_root}"
}

# https://www.terraform.io/docs/providers/aws/r/route53_zone.html
# resource "aws_route53_record" "ns" {
#   # count = "${1 - var.private_enabled}"


#   # https://github.com/hashicorp/terraform/issues/12570
#   # TODO: Should be fixed in 0.12
#   # count   = "${var.vpc_id == "" ? 1 : 0}"
#   zone_id = "${data.aws_route53_zone.zone_root.zone_id}"


#   name = "${var.domain_name}"
#   type = "NS"
#   ttl  = "30"


#   records = [
#     "${aws_route53_zone.zone.name_servers.0}",
#     "${aws_route53_zone.zone.name_servers.1}",
#     "${aws_route53_zone.zone.name_servers.2}",
#     "${aws_route53_zone.zone.name_servers.3}",
#   ]
# }

