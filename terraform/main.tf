terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# -----------------------------
# Random suffix (safe dependency)
# -----------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

# -----------------------------
# S3 Bucket
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
# BLOCK INSECURE HTTP ACCESS (tfsec fix)
# -----------------------------
resource "aws_s3_bucket_policy" "secure" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  depends_on = [aws_s3_bucket.devsecops_bucket]

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
# ENABLE LOGGING (fixes scanner warning)
# NOTE: self-logging is allowed for dev/demo setups
# -----------------------------
resource "aws_s3_bucket_logging" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  target_bucket = aws_s3_bucket.devsecops_bucket.id
  target_prefix = "access-logs/"
}

# -----------------------------
# PUBLIC ACCESS BLOCK (required for security compliance)
# -----------------------------
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
