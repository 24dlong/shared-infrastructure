terraform {
  backend "s3" {
    bucket       = "24dlong-shared-infrastructure-prod-terraform-state"
    key          = "24dlong-shared-infrastructure/bootstrap/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
