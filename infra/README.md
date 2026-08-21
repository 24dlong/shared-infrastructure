# infra

Single Terraform root applied to **every** environment (today: only
`production`; more will be added over time without any changes here). This
directory holds the one and only definition of this account family's
shared-foundation resources:

- GitHub Actions OIDC provider (`token.actions.githubusercontent.com`)
- Repo/environment-scoped deploy + plan IAM roles for `24dlong/shared-infrastructure`

Differences between environments (separate AWS account, state bucket/key,
any future sizing/tuning) are supplied entirely through Terraform variables
and backend configuration at `init`/`plan`/`apply` time — **never** by
copying this code into a per-environment directory. See `/ARCHITECTURE.md`
for the full model and `../environments/<env>/README.md` for each
environment's concrete values.

## Backend

The `backend "s3" {}` block in `versions.tf` is intentionally empty (a
partial configuration). Real values are always supplied via
`-backend-config` flags at `terraform init` time:

```sh
cd infra
terraform init \
  -backend-config="bucket=<STATE_BUCKET>" \
  -backend-config="key=<STATE_KEY>" \
  -backend-config="region=<STATE_REGION>" \
  -backend-config="use_lockfile=true"
```

In CI these values come from the target environment's GitHub Environment
variables, injected as `TF_CLI_ARGS_init` by the library GitOps deploy
workflow (called from `.github/workflows/pull-request-deploy.yml` and
`merge-deploy.yml`).

## Variables

Any variable in `variables.tf` can be overridden per environment via
`environments/<env>/terraform.tfvars` (CI, passed automatically as
`-var-file` by the library GitOps deploy workflow) or `-var-file`/`-var`
(local). Defaults match the current `production` environment; new
environments only need to override what actually differs (e.g.
`name_prefix`, `state_bucket_name`, `state_key_prefix`). See
`/ARCHITECTURE.md`'s "Where environment values live" for why this is a git
file rather than a GitHub Environment variable.
