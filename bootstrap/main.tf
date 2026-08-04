provider "aws" {
  region = var.aws_region
}

module "terraform_state" {
  source = "git::https://github.com/24dlong/terraform-modules-library.git//modules/terraform-state?ref=0.3.0"

  name_prefix = var.name_prefix
  tags        = var.tags
}
