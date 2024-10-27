output "ec2_public_ip" {
  description = "ec2 public_ip"
  value       = aws_instance.mainnet.public_ip
}


