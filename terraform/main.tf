terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# -----------------------------
# Random suffix (required)
# -----------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

# -----------------------------
# S3 Bucket (fixed)
# -----------------------------
resource "aws_s3_bucket" "devsecops_bucket" {
  bucket = "devsecops-demo-bucket-${random_id.suffix.hex}"

  tags = {
    Project     = "devsecops-pipeline"
    Environment = "dev"
    Owner       = "wcdennis38"
  }
}
