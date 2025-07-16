terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"  # Consider using Jenkins credentials
  secret_key                  = "test"  # Consider using Jenkins credentials
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3 = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-localstack-bucket-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  force_destroy = true

  tags = {
    Environment = "LocalStack"
    ManagedBy   = "Terraform"
    Pipeline    = "Jenkins"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}
