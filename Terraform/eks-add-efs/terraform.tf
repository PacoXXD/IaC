terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-backend-state"
    dynamodb_table = "terraform-backend-lock"
    region         = "us-west-2"
    key            = "prd/eks-add-efs/terraform.tfstate"
  }
}
