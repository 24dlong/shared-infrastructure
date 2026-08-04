variable "aws_region" {
  description = "AWS region used for production shared-foundation resources."
  type        = string
  default     = "us-east-2"
}

variable "name_prefix" {
  description = "Prefix used to name production shared-foundation resources."
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
  description = "Terraform state bucket name created by bootstrap."
  type        = string
  default     = "24dlong-shared-infrastructure-prod-terraform-state"
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
