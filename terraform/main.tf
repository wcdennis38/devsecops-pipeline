terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source = "hashicorp/random"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# -----------------------------
# Random suffix
# -----------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

# -----------------------------
# S3 Bucket (secure baseline)
# -----------------------------
resource "aws_s3_bucket" "devsecops_bucket" {
  bucket = "devsecops-demo-bucket-${random_id.suffix.hex}"

  tags = {
    Project     = "devsecops-pipeline"
    Environment = "dev"
    Owner       = "wcdennis38"
  }
}

# -----------------------------
# Block ALL non-HTTPS access
# -----------------------------
resource "aws_s3_bucket_policy" "https_only" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource  = [
          aws_s3_bucket.devsecops_bucket.arn,
          "${aws_s3_bucket.devsecops_bucket.arn}/*"
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

# -----------------------------
# ENABLE ACCESS LOGGING (fixes logging warning)
# -----------------------------
resource "aws_s3_bucket" "log_bucket" {
  bucket = "devsecops-logs-${random_id.suffix.hex}"

  tags = {
    Project     = "devsecops-pipeline"
    Environment = "dev"
    Owner       = "wcdennis38"
  }
}

resource "aws_s3_bucket_logging" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "access-logs/"
}
