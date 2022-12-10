variable "env" {
  type = string
}

variable "v_tag" {
  type = string
}

variable "region" {
  type = string
}

variable "es_domain_name" {
  type = string
}

variable "sg_id" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}