terraform {
  required_version = ">= 1.2.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34.0"
    }
  }
  backend "s3" {
    encrypt        = true
    bucket         = "terraform-backend-state"
    dynamodb_table = "terraform-backend-lock"
    region         = "us-west-2"
    key            = "stg/stg-kafkacluster-backend/terraform.tfstate"
  }
}
