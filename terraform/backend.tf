terraform {
  backend "s3" {
    bucket = "devsecops-terraform-state-waynedennis-001"
    key    = "devsecops/terraform.tfstate"
    region = "us-east-1"
  }
}
