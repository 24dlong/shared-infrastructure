# Bootstrap Root

This root creates the shared Terraform state bucket.

## One-time bootstrap flow

1. Start with local state (this directory intentionally has no `backend "s3"` block).
2. Run:
   - `terraform init`
   - `terraform apply`
3. Capture output `state_bucket_id`.
4. Create a new `backend.tf` in this directory:

```hcl
terraform {
  backend "s3" {
    bucket       = "24dlong-shared-infrastructure-prod-terraform-state"
    key          = "24dlong-shared-infrastructure/bootstrap/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true
  }
}
```

5. Run `terraform init -migrate-state` to move bootstrap state from local to S3.

After step 5, this root should continue to use S3 state.

## Production first apply

The OIDC roles do not exist yet. First apply must run locally with your own
AWS credentials:

1. `cd production`
2. `terraform init`
3. `terraform apply`

After this succeeds, run `terraform output` and set repository variables for workflows:
- `AWS_ROLE_ARN_PLAN` = output `shared_infrastructure_plan_role_arn`
- `AWS_ROLE_ARN_APPLY` = output `shared_infrastructure_deploy_role_arn`
