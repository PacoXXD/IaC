variable "env" {
  type = string
}

variable "v_tag" {
  type = string
}

variable "my_ip" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "vpc_id" {
  type = map(string)
}

variable "public_subnet_id" {
  type = map(string)
}

variable "amis" {
  type = map(string)
}



variable "ssh_user" {
  type = string
}


variable "instance_num" {
  type = number
}

variable "instance_type" {
  type = map(string)
}

variable "key_name" {
  type = map(string)
}

variable "prunedfile_name" {
  type = string
}


