terraform {
  required_version = ">= 1.6.6"

  backend "s3" {
    bucket         = "REPLACE_WITH_REAL_BUCKET"
    key            = "devsecops-pipeline/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "REPLACE_WITH_REAL_LOCK_TABLE"
    encrypt        = true
  }
}
