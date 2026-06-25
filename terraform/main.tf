terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# -----------------------------
# S3 Bucket
# -----------------------------
resource "aws_s3_bucket" "this" {
  bucket = "devsecops-pipeline-bucket-${random_id.suffix.hex}"

  tags = {
    Project     = "devsecops-pipeline"
    Environment = "dev"
    Owner       = "wcdennis38"
  }
}

# -----------------------------
# Random suffix for uniqueness
# -----------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

# -----------------------------
# Block public / enforce HTTPS
# -----------------------------
resource "aws_s3_bucket_policy" "secure" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
