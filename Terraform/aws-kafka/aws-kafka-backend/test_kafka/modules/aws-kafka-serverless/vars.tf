variable "name" {
  type = string
}

variable "msk_name" {
  type = string
}

variable "allowed_sg_ids" {
  description = "Security group that is allowed access to mks"
  type        = list(string)
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}





