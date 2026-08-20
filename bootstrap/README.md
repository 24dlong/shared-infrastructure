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

## First apply for a new environment

This directory is reusable per environment/account: run it once for each new
account with that account's own AWS credentials and inputs (e.g.
`-var name_prefix=... -var aws_region=...`), following the same local-state
→ migrate-to-S3 flow above.

The OIDC roles created by `infra/` do not exist yet on first run for a new
environment. First apply must run locally with your own AWS credentials:

1. `cd infra`
2. `terraform init -backend-config="bucket=<STATE_BUCKET>" -backend-config="key=<STATE_KEY>" -backend-config="region=<STATE_REGION>" -backend-config="use_lockfile=true"`
3. `terraform apply -var-file=../environments/<env>/terraform.tfvars` (create
   that file first with this environment's overrides — see
   `../environments/production/terraform.tfvars` for the shape)

After this succeeds, run `terraform output` and set that environment's
GitHub Environment variables:
- `AWS_ROLE_ARN_PLAN` = output `shared_infrastructure_plan_role_arn`
- `AWS_ROLE_ARN_APPLY` = output `shared_infrastructure_deploy_role_arn`
- `STATE_BUCKET` / `STATE_KEY` / `STATE_REGION` = the backend-config values used above

See `/ARCHITECTURE.md` for the full "add a new environment" runbook.
