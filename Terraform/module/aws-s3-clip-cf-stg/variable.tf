variable "subdomain" {
  type = "string"
}

variable "domain" {
  type = "string"
}

variable "name" {
  type = "string"
}

variable "allowed_origins" {
  type = "list"
}

variable "route53_enabled" {
  type = "string"
}

variable "price_class" {
  type = "string"
}

variable "acm_cert_arn" {
  type = "string"
}

# TODO: Might not work
# https://github.com/hashicorp/terraform/issues/17668
variable "lifecycle_rule" {
  type    = "list"
  default = []
}

variable "s3_access_log_bucket" {
  type = "string"
}
