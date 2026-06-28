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
# Random suffix
# -----------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

# -----------------------------
# Customer-managed KMS key
# -----------------------------
resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Project     = "devsecops-pipeline"
    Environment = "dev"
  }
}

resource "aws_kms_alias" "s3" {
  name          = "alias/devsecops-s3"
  target_key_id = aws_kms_key.s3.key_id
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
# Public Access Block
# -----------------------------
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------
# Versioning
# -----------------------------
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------
# KMS Encryption (Fixes AWS-0132)
# -----------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }

    bucket_key_enabled = true
  }
}

# -----------------------------
# Ownership Controls
# -----------------------------
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# -----------------------------
# HTTPS Only Policy
# -----------------------------
resource "aws_s3_bucket_policy" "secure" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "DenyInsecureTransport"

        Effect = "Deny"

        Principal = "*"

        Action = "s3:*"

        Resource = [
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
# Access Logging
# -----------------------------
resource "aws_s3_bucket_logging" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  target_bucket = aws_s3_bucket.devsecops_bucket.id
  target_prefix = "access-logs/"
}
