# output "endpoint" {
#   # value = "${join(":", list(element(concat(aws_route53_record.redis.0.name), 0), aws_elasticache_replication_group.redis.cache_nodes.0.port))}"
#   value = "${var.zone_id != "" ? "${join(":", list(element(concat(aws_route53_record.redis_cluster.*.name, list("")), 0), aws_elasticache_replication_group.redis_cluster.0.port))}" : "${join(":", list(aws_elasticache_replication_group.redis_cluster.0.configuration_endpoint_address, aws_elasticache_replication_group.redis_cluster.0.port))}"}"
# }

# output "address" {
#   value = "${var.zone_id != "" ? "${element(concat(aws_route53_record.redis_cluster.*.name, list("")), 0)}" : "${aws_elasticache_replication_group.redis_cluster.0.configuration_endpoint_address}"}"
# }

output "redis_endpoint" {
  value = "${element(concat(aws_elasticache_replication_group.redis_cluster.*.configuration_endpoint_address, list("")), 0)}"
}
