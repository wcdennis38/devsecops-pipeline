terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "devsecops_bucket" {
  bucket = "devsecops-demo-bucket-${random_id.suffix.hex}"
}
