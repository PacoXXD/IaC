region = "us-east-1"
env    = "stg"
v_tag  = "20221009"

vpc_id         = "vpc-0e26e2cc0195b9b92"

client_subnets = ["subnet-0c277c7aa1444f8f0","subnet-0b426c27b6580587d","subnet-05780028e3ef3a558"]
allowed_sg_ids     = ["sg-049eb873bf675354b"]
name = "stg-app"

msk_name = "backend"