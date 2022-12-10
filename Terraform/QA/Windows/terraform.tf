# Terraform Block
terraform {
  required_version = ">= 1.1.9"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.14"
  
  }
}

  backend "s3" {
    encrypt        = true
    bucket         = "terraform-backend-state"
    dynamodb_table = "terraform-backend-lock"
    region         = "us-west-2"
    key            = "qa/window-server/terraform.tfstate"
  }
      }

# Provider Block
provider "aws" {
  region  = var.aws_region
  profile = "default"
}

