variable "name" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "vpc_id" {
  type = "string"
}

variable "allowed_sg_ids" {
  type = "list"
}

variable "instance_type" {
  type = "string"
}

variable "allowed_cidr" {
  type    = "string"
  default = ""
}

variable "zone_id" {
  type    = "string"
  default = ""
}

variable "name_no_env" {
  type    = "string"
  default = ""
}

variable "domain" {
  type    = "string"
  default = ""
}

variable "num_replica" {
  type = "string"
}

variable "node_groups" {
  type = "string"
}

variable "redis_endpoint" {
  type    = "string"
  default = ""
}
