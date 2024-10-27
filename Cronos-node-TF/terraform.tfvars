env = "mainnet"

v_tag = "v1026"

aws_region = "eu-central-1"

my_ip = "xx.xx.184.77/32" //your ip

instance_num = 1

instance_type = {
  eu-west-1 = "t2.micro"

  eu-central-1 = "c5.4xlarge"
}

amis = {
  eu-central-1 = "ami-0e9377e5e340374c9"
  eu-west-1    = "ami-0a422d70f727fe93e"
}

key_name = {
  eu-central-1 = "frankfurt-key-pair"
  eu-west-1    = "ireland-key-pair"
}


ssh_user = "ubuntu"


public_subnet_id = {
  eu-central-1 = "subnet-xxxxxxxxxx"
}

vpc_id = {
  eu-central-1 = "vpc-xxxxxxxxxxxx"
}

prunedfile_name = "cronos-pos-pruned-20310086-20310096.tar.lz4" //input the latest file name from https://www.publicnode.com/snapshots#cronos
