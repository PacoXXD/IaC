region = "eu-west-1"
env    = "stg"
v_tag  = "20221008"

vpc_id         = "vpc-0519910f642ca51da"

# # stg public subnets
# client_subnets = ["subnet-0f80974e5c0dc1ab8","subnet-02bfdd0a5b5d67f82","subnet-046b16170d84839da"]
# stg private subnets
client_subnets = ["subnet-09338f65f83809ca9","subnet-0b556e9586ac8c1bf","subnet-0d881ac1a6bd0d13a"]

allowed_sg_ids     = ["sg-0b3b7b30f2a6cb430","sg-0f3e3fac988e0588f"]
name = "backend"
