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
# RANDOM SUFFIX
# -----------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

# =========================================================
# LOG BUCKET (FIXES LOGGING SECURITY WARNING)
# =========================================================
resource "aws_s3_bucket" "log_bucket" {
  bucket = "devsecops-logs-${random_id.suffix.hex}"

  tags = {
    Purpose = "access-logs"
    Owner   = "wcdennis38"
  }
}

resource "aws_s3_bucket_public_access_block" "log_block" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_encryption" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# =========================================================
# MAIN S3 BUCKET
# =========================================================
resource "aws_s3_bucket" "devsecops_bucket" {
  bucket = "devsecops-demo-bucket-${random_id.suffix.hex}"

  tags = {
    Project     = "devsecops-pipeline"
    Environment = "dev"
    Owner       = "wcdennis38"
  }
}

# -----------------------------
# OWNERSHIP CONTROLS (FIRST)
# -----------------------------
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# -----------------------------
# PUBLIC ACCESS BLOCK (DEPENDENT)
# -----------------------------
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  depends_on = [
    aws_s3_bucket_ownership_controls.this
  ]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------
# VERSIONING
# -----------------------------
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]

  versioning_configuration {
    status = "Enabled"
  }
}

# -----------------------------
# ENCRYPTION (AES256 - NO KMS ISSUES)
# -----------------------------
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  depends_on = [
    aws_s3_bucket_versioning.this
  ]

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------------
# ACCESS LOGGING (FIXES SECURITY WARNING)
# -----------------------------
resource "aws_s3_bucket_logging" "this" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "access-logs/"

  depends_on = [
    aws_s3_bucket_server_side_encryption_configuration.this
  ]
}

# -----------------------------
# HTTPS-ONLY POLICY
# -----------------------------
resource "aws_s3_bucket_policy" "secure" {
  bucket = aws_s3_bucket.devsecops_bucket.id

  depends_on = [
    aws_s3_bucket_public_access_block.this
  ]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyInsecureTransport"
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
# OUTPUT
# -----------------------------
output "bucket_name" {
  value = aws_s3_bucket.devsecops_bucket.bucket
}

output "log_bucket_name" {
  value = aws_s3_bucket.log_bucket.bucket
}
