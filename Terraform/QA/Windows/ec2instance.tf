# EC2 Instance
resource "aws_instance" "stgWindows" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.instance_keypair
  vpc_security_group_ids = [ aws_security_group.vpc-rdp.id, aws_security_group.vpc-web.id   ]
  tags = {
    "Name" = "Windows for stg"
  }
}
