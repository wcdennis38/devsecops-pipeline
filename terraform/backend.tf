terraform {
  required_version = ">= 1.6.6"

  backend "s3" {
    bucket         = "YOUR_TF_STATE_BUCKET_NAME"
    key            = "devsecops-pipeline/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "YOUR_TF_LOCK_TABLE_NAME"
    encrypt        = true
  }
}
