output "zone_id" {
  value = "${element(concat(aws_route53_zone.zone.*.zone_id, aws_route53_zone.zone_private.*.zone_id), 0)}"
}
