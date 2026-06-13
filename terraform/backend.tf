terraform {
  backend "s3" {
    bucket  = "devsecops-terraform-state-wc-dennis-001"
    key     = "devsecops/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
