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

resource "random_id" "suffix" {
  byte_length = 4
}

# =====================================================
# LOG BUCKET
# =====================================================
resource "aws_s3_bucket" "log_bucket" {
  bucket = "prod-logs-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_ownership_controls" "log" {
  bucket = aws_s3_bucket.log_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "log" {
  bucket = aws_s3_bucket.log_bucket.id

  depends_on = [aws_s3_bucket_ownership_controls.log]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "log" {
  bucket = aws_s3_bucket.log_bucket.id

  depends_on = [aws_s3_bucket_public_access_block.log]

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log" {
  bucket = aws_s3_bucket.log_bucket.id

  depends_on = [aws_s3_bucket_versioning.log]

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# =====================================================
# MAIN BUCKET
# =====================================================
resource "aws_s3_bucket" "main" {
  bucket = "prod-bucket-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_ownership_controls" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket = aws_s3_bucket.main.id

  depends_on = [aws_s3_bucket_ownership_controls.main]

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  depends_on = [aws_s3_bucket_public_access_block.main]

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  depends_on = [aws_s3_bucket_versioning.main]

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# =====================================================
# HTTPS ONLY POLICY (FIXED SCANNER DETECTION)
# =====================================================
resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id

  depends_on = [
    aws_s3_bucket_public_access_block.main,
    aws_s3_bucket_ownership_controls.main,
    aws_s3_bucket_server_side_encryption_configuration.main
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
          aws_s3_bucket.main.arn,
          "${aws_s3_bucket.main.arn}/*"
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

# =====================================================
# LOGGING (CIS SAFE + DETECTABLE)
# =====================================================
resource "aws_s3_bucket_logging" "main" {
  bucket = aws_s3_bucket.main.id

  depends_on = [
    aws_s3_bucket_server_side_encryption_configuration.main,
    aws_s3_bucket_server_side_encryption_configuration.log,
    aws_s3_bucket_public_access_block.main,
    aws_s3_bucket_public_access_block.log
  ]

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "access-logs/"
}

# =====================================================
# OUTPUT
# =====================================================
output "bucket_name" {
  value = aws_s3_bucket.main.bucket
}
