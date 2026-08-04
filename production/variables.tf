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
  description = "GitHub org/user allowed to assume this deployment role."
  type        = string
  default     = "24dlong"
}

variable "github_repo" {
  description = "GitHub repository allowed to assume this deployment role."
  type        = string
  default     = "24dlong-shared-infrastructure"
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
