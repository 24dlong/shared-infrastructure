terraform {
  required_version = ">= 1.9, < 2.0.0"

  backend "s3" {
    bucket       = "24dlong-shared-infrastructure-prod-terraform-state"
    key          = "24dlong-shared-infrastructure/production/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 7.0.0"
    }
  }
}
