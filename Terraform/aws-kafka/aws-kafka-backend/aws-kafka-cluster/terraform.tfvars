region = "eu-west-1"
env    = "stg"
v_tag  = "20221009"

name   = "backend"
vpc_id = "vpc-0519910f642ca51da"

client_subnets = ["subnet-09338f65f83809ca9", "subnet-0d881ac1a6bd0d13a", "subnet-0b556e9586ac8c1bf"]
allowed_sg_ids = ["sg-0b3b7b30f2a6cb430","sg-0f3e3fac988e0588f","sg-0b3b7b30f2a6cb430","sg-0f3e3fac988e0588f"]
instance_type  = "kafka.m5.large"

