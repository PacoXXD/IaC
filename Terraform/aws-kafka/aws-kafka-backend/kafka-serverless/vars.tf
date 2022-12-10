variable "env" {
  type = string
}

variable "v_tag" {
  type = string
}

variable "region" {
  type = string
}

variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "client_subnets" {
  type = list(string)
}

variable "allowed_sg_ids" {
  description = "Security group that is allowed access to mks"
  type        = list(string)
}




