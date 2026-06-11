provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "devsecops_bucket" {
  bucket = "devsecops-demo-bucket-123456789"
}
