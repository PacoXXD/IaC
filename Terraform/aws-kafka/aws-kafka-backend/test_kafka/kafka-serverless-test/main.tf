module "msk_backend_serverless" {
  source = "../modules/aws-kafka-serverless"

  name         = format("%s-msk-serverless", var.env)
 
  vpc_id = var.vpc_id
  allowed_sg_ids = var.allowed_sg_ids
  msk_name = format("%s-msk-serverless", var.name)
  subnet_ids = var.client_subnets

}
