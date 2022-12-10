variable "domain_name" {
  type = "string"
}

variable "domain_root" {
  type = "string"
}

variable "comment" {
  type = "string"
}

variable "vpc_id" {
  type    = "string"
  default = ""
}

variable "private_enabled" {
  type    = "string"
  default = 0
}
