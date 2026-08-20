# production environment

- Terraform variable values: [`terraform.tfvars`](./terraform.tfvars). Passed
  automatically to `terraform plan` by the library GitOps deploy workflow, so
  any change to it shows up in the plan diff before it takes effect.
- GitHub Environment: `production` (repo Settings → Environments), holding:
  - `AWS_ROLE_ARN_PLAN` / `AWS_ROLE_ARN_APPLY` — this environment's OIDC role
    ARNs (from `infra` outputs `shared_infrastructure_plan_role_arn` /
    `shared_infrastructure_deploy_role_arn`)
  - `STATE_BUCKET`, `STATE_KEY`, `STATE_REGION` — backend-config values
    injected via `TF_CLI_ARGS_init` in the deploy workflows

These five stay as GitHub Environment variables rather than moving into
`terraform.tfvars`: they control where this environment's Terraform state is
written and which AWS identity CI assumes, both resolved before any plan is
generated. A git file wouldn't get a plan-diff review; a GitHub Environment
variable requires repo/environment admin access to change. See
`/ARCHITECTURE.md`'s "Where environment values live" section.

This is currently the **lowest environment**. Every merge to `main` that
touches `infra/**` automatically opens a PR bumping `deployed.json` (below),
which is then planned (`.github/workflows/pull-request-deploy.yml`) and
applied (`.github/workflows/merge-deploy.yml`) once that PR is merged.

## deployed.json

`deployed.json` in this directory is the desired-state record for this
environment: the ref/sha it should currently be running. It is normally only
ever modified by the automated PR opened by `merge.yml`'s
`request-deploy-production` job (and, once built, a future promotion
workflow). Avoid hand-editing it outside of the initial backfill.
