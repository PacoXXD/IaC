variable "bucket_name" {
  description = "Bucket name were the bastion will store the logs"
}

variable "bucket_versioning" {
  default     = true
  description = "Enable bucket versioning or not"
}

variable "region" {
  type = "string"
}

variable "lb_internal" {
  description = "If TRUE the load balancer scheme will be \"internal\" else \"internet-facing\""
}

variable "vpc_id" {
  description = "VPC id were we'll deploy the bastion"
}

variable "bastion_key_pair" {
  description = "Select the key pair to use to launch the bastion host"
}

variable "domain" {
  type = "string"
}

variable "zone_id" {
  type = "string"
}

variable "subdomain" {
  type = "string"
}

variable "subnet_ids" {
  type        = "list"
  description = "List of subnet were the ELB will be deployed"
}

variable "subnet_count" {
  type = "string"
}

variable "bastion_amis" {
  type = "map"

  default = {
    "us-east-1"      = "ami-f5f41398"
    "us-west-2"      = "ami-d0f506b0"
    "us-west-1"      = "ami-6e84fa0e"
    "eu-west-1"      = "ami-022e8cc8f0d3c52fd"
    "eu-central-1"   = "ami-0bdf93799014acdc4"
    "ap-southeast-1" = "ami-1ddc0b7e"
    "ap-northeast-2" = "ami-cf32faa1"
    "ap-northeast-1" = "ami-29160d47"
    "ap-southeast-2" = "ami-0c95b86f"
    "sa-east-1"      = "ami-fb890097"
  }
}

variable "bastion_instance_count" {
  default = 1
}

variable "route53_enabled" {
  description = "Choose if you want to create a record name for the bastion (LB). If true 'hosted_zone_name' and 'bastion_record_name' are mandatory "
  default     = false
}

variable "log_auto_clean" {
  description = "Enable or not the lifecycle"
  default     = false
}

variable "log_standard_ia_days" {
  description = "Number of days before moving logs to IA Storage"
  default     = 30
}

variable "log_glacier_days" {
  description = "Number of days before moving logs to Glacier"
  default     = 60
}

variable "log_expiry_days" {
  description = "Number of days before logs expiration"
  default     = 90
}

variable "name" {
  type = "string"
}

variable "allowed_cidr" {
  type = "string"
}

variable "instance_type" {
  type = "string"
}
