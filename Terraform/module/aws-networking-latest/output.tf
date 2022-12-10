output "vpc_id" {
  description = "VPC id"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}

output "subnet_public_ids" {
  description = "Public subnets' ids"
  value       = module.vpc.public_subnets
}

output "subnet_private_ids" {
  description = "Private subnets' ids"
  value       = module.vpc.private_subnets
}

output "azs" {
  description = "AZs of VPC"
  value       = data.aws_availability_zones.available.names
}

output "nat_public_ips" {
  value = module.vpc.nat_public_ips
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

