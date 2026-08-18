terraform {
  required_version = ">= 1.9, < 2.0.0"

  # Intentionally empty (partial configuration): this single root is applied
  # to every environment, each with its own isolated S3 bucket/key/region.
  # The real values are supplied at `terraform init` time via
  # `-backend-config=...` flags (in CI, via the TF_CLI_ARGS_init env var set
  # from that environment's GitHub Environment variables). See
  # /ARCHITECTURE.md and ../environments/<env>/README.md.
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 7.0.0"
    }
  }
}
