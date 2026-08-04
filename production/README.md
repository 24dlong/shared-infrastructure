# Production Root

This root creates identity resources for shared-foundation automation:

- GitHub Actions OIDC provider (`token.actions.githubusercontent.com`)
- Repo/branch-scoped deploy role for `24dlong/shared-infrastructure`

It uses the bootstrap-created state bucket backend:

- Bucket: `shared-infrastructure-prod-terraform-state`
- Key: `shared-infrastructure/production/terraform.tfstate`
- Region: `us-east-2`
- Locking: `use_lockfile = true`

## First apply note

The deploy role created by this root does not exist yet on first run.
Run the first `terraform apply` manually with your own AWS credentials.
After the role exists, subsequent plan/apply runs can use GitHub OIDC.
