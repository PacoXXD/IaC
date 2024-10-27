terraform {
  required_version = ">= 1.4.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.34.0"
    }
  }

  backend "s3" {
    encrypt        = true
    bucket         = "xxxx-backend-state-file"
    dynamodb_table = "terraform-xxxxx-lock-dynamo"
    key            = "xxx/cronsec34/terraform.tfstate"
    region         = "eu-west-1"
  }
}

