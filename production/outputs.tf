output "state_bucket_name" {
  description = "Shared S3 state bucket used by production root."
  value       = var.state_bucket_name
}

output "tags" {
  description = "Common tags applied to shared-foundation resources, for downstream consumers to merge into their own resource tags."
  value       = var.tags
}

output "state_bucket_region" {
  description = "Region of the shared S3 state bucket."
  value       = var.aws_region
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider in this account."
  value       = module.github_oidc.oidc_provider_arn
}

output "shared_infrastructure_deploy_role_arn" {
  description = "ARN of the apply role scoped to repo:24dlong/shared-infrastructure on main branch."
  value       = module.github_oidc.role_arn
}

output "shared_infrastructure_deploy_role_name" {
  description = "Name of the apply role scoped to repo:24dlong/shared-infrastructure on main branch."
  value       = module.github_oidc.role_name
}

output "shared_infrastructure_plan_role_arn" {
  description = "ARN of the read-only plan role scoped to repo:24dlong/shared-infrastructure across branches."
  value       = module.github_oidc_plan.role_arn
}

output "shared_infrastructure_plan_role_name" {
  description = "Name of the read-only plan role scoped to repo:24dlong/shared-infrastructure across branches."
  value       = module.github_oidc_plan.role_name
}
