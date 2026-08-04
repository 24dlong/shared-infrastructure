output "state_bucket_id" {
  description = "Name of the Terraform state bucket created by bootstrap."
  value       = module.terraform_state.bucket_id
}

output "state_bucket_arn" {
  description = "ARN of the Terraform state bucket created by bootstrap."
  value       = module.terraform_state.bucket_arn
}

output "state_bucket_region" {
  description = "Region of the Terraform state bucket created by bootstrap."
  value       = module.terraform_state.bucket_region
}
