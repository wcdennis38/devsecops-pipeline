terraform {
  backend "s3" {
    bucket = "devsecops-demo-state"
    key    = "terraform/state.tfstate"
    region = "us-east-1"
  }
  required_version = ">= 1.6.6"
}
