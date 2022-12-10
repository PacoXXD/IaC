variable "cidr" {
  type = string
}

variable "name" {
  type = string
}

variable "vpc_tags" {
  type    = map(string)
  default = {}
}

variable "subnet_private_tags" {
  type    = map(string)
  default = {}
}

variable "subnet_public_tags" {
  type    = map(string)
  default = {}
}

variable "create" {
  type    = string
  default = true
}

variable "secondary_cidr_blocks" {
  type    = list(string)
  default = [ ]
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}
variable "single_nat_gateway" {
  type    = bool
  default = true
}