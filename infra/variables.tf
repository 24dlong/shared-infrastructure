variable "aws_region" {
  description = "AWS region used for this environment's shared-foundation resources."
  type        = string
  default     = "us-east-2"
}

variable "name_prefix" {
  description = "Prefix used to name this environment's shared-foundation resources."
  type        = string
  default     = "24dlong-shared-infrastructure-prod"
}

variable "github_org" {
  # GitHub has enabled immutable OIDC subject claims for this repo, so the
  # `sub` claim embeds the org's numeric ID (repo:ORG@ORG_ID/REPO@REPO_ID:...).
  # See https://docs.github.com/en/actions/reference/security/oidc#immutable-subject-claims
  description = "GitHub org/user (with immutable ID) allowed to assume this deployment role."
  type        = string
  default     = "24dlong@24920691"
}

variable "github_repo" {
  # See note on github_org above re: immutable subject claim IDs.
  description = "GitHub repository (with immutable ID) allowed to assume this deployment role."
  type        = string
  default     = "shared-infrastructure@1323258551"
}

variable "github_branch" {
  description = "GitHub branch allowed to assume this deployment role."
  type        = string
  default     = "main"
}

variable "state_bucket_name" {
  description = "Terraform state bucket name created by bootstrap for this environment's account."
  type        = string
  default     = "24dlong-shared-infrastructure-prod-terraform-state"
}

variable "state_key_prefix" {
  description = <<-EOT
    Key prefix (within the state bucket) under which this environment's own
    Terraform state objects live. Used to scope the deployer/planner IAM
    policies to only this environment's own state path. Differs per
    environment only if multiple environments ever share one bucket; today
    each environment has its own account/bucket, so this mainly documents
    the convention.
  EOT
  type        = string
  default     = "24dlong-shared-infrastructure/production"
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
  default = {
    Project     = "24dlong-shared-infrastructure"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
