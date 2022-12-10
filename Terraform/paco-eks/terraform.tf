terraform {
  required_version = ">= 1.2.5"

  required_providers {
      aws = {
      source  = "hashicorp/aws"
      version = "~> 4.22.0"
    }
  }
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-backend-state"
    dynamodb_table = "terraform-backend-lock"
    region         = "us-west-2"
    key            = "prd/prd-uppaco-eks/terraform.tfstate"
  }
}
