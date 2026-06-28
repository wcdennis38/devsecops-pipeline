# Terraform Variables

aws_region   = "us-east-1"
environment  = "dev"
project_name = "devsecops-pipeline"

tags = {
  Owner       = "DevSecOps"
  CostCenter  = "Engineering"
  Compliance  = "CIS-AWS-Foundations"
  ScanTools   = "Trivy-Checkov"
}
