variable "environment" {
  description = <<-EOT
    GitHub Environment whose jobs may assume this environment's plan and
    apply roles (`repo:<org>/<repo>:environment:<name>`). Must match the
    GitHub Environment name used by terraform-deploy.yml (environments/<env>/).
  EOT
  type        = string
}

variable "aws_region" {
  description = "AWS region used for this environment's shared-foundation resources."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used to name this environment's shared-foundation resources."
  type        = string
}

variable "state_bucket_name" {
  description = "Terraform state bucket name created by bootstrap for this environment's account."
  type        = string
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
}

variable "tags" {
  description = "Common tags applied to resources."
  type        = map(string)
}
