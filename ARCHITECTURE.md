# Architecture: single-root, multi-environment Terraform + GitOps deployment

This document is the source of truth for how `shared-infrastructure` manages
multiple environments over time. Read this before changing the Terraform
layout, the CI workflows, or onboarding a new environment.

## Goals

1. **One copy of the Terraform code**, applied identically to every
   environment. No per-environment forks/copies of `.tf` files — that's
   where drift comes from.
2. **Full isolation per environment**: each environment is a separate AWS
   account with its own state bucket, its own OIDC provider, its own IAM
   roles. A mistake or compromise in one environment cannot touch another.
3. **The lowest environment (today: `production`) is applied automatically**
   on every merge to `main` that touches `infra/**`.
4. **Promotion to upper environments** (future) reuses the exact same
   mechanism used for the lowest environment — no bespoke pipeline per
   environment.
5. **Always know what's running where.** Every environment's currently
   applied ref/sha is recorded in git, not just in CI logs or tribal
   knowledge.

## Repo layout

```
infra/                        # THE single Terraform root — applied to every environment
  main.tf                     # OIDC provider + plan/apply IAM roles (one definition, shared)
  variables.tf                # all variables; environment differences = variable values only
  outputs.tf
  versions.tf                 # required_providers + an EMPTY backend "s3" {} block
  README.md

bootstrap/                    # reusable, one-time-per-environment tooling
  main.tf / variables.tf / outputs.tf / versions.tf
  README.md                   # run once per new account, parameterized by inputs

environments/
  production/
    README.md                 # this environment's account/region/bucket/key/role facts
    terraform.tfvars           # Terraform variable overrides for this environment
    deployed.json              # desired-state record: the ref/sha this environment should run
  # staging/, uat/, etc. added later — same three files, no new Terraform code

.github/workflows/
  pull-request.yml            # standard PR pipeline: quality-gate only
  merge.yml                    # standard merge pipeline: quality-gate + create version + request deploy (opens deployed.json bump PR)
  pull-request-deploy.yml     # thin wrapper: PR on environments/**/deployed.json → library GitOps plan
  merge-deploy.yml            # thin wrapper: merge of environments/**/deployed.json → library GitOps apply
```

`production/` (the old combined "identity + environment" root) no longer
exists — its Terraform content moved into `infra/`, and its
environment-specific facts moved into `environments/production/`.

## Why one Terraform root, not one per environment

The old layout had exactly one environment (`production/`) containing both
the reusable OIDC/IAM-role logic *and* that environment's specific values
hardcoded (bucket name, region, etc.) in the same files. Naively adding a
second environment by copying that directory would mean the OIDC provider
resource definition exists twice — any bugfix, security tightening, or
policy change would need to be applied (and tested) N times, and could
silently drift between environments.

Instead, `infra/` contains **only** the resource definitions. Every
environment applies the *same* `infra/` code; the only things that differ
per environment are:
- **Backend configuration** (bucket, key, region) — supplied at `terraform
  init` time, never hardcoded in `infra/`.
- **Variable values** — supplied via `environments/<env>/terraform.tfvars`
  (CI, via `-var-file`) or `-var-file`/`-var` (local); `infra/variables.tf`'s
  defaults describe `production` today, and only the deltas need overriding
  for a new environment.

## Where environment values live

Not every per-environment value belongs in the same place. The dividing
line is whether a value shows up in the `terraform plan` diff before it
takes effect:

- **Shows up in the plan** (`environments/<env>/terraform.tfvars`): ordinary
  Terraform variables — `name_prefix`, `environment`, `state_bucket_name`,
  `state_key_prefix`, `tags`, etc. A change here is visible in the PR's plan
  comment before it's ever applied, so a normal PR review is a sufficient
  safety net. It's a git file: any approved PR can change it.
- **Takes effect before any plan exists** (GitHub Environment variables,
  admin-gated): `STATE_BUCKET` / `STATE_KEY` / `STATE_REGION` (which state
  file gets written) and `AWS_ROLE_ARN_PLAN` / `AWS_ROLE_ARN_APPLY` (which
  AWS identity CI assumes). Both are resolved during `terraform init` /
  credential setup, before `terraform plan` runs, so there's no plan diff to
  review. Changing them requires GitHub Environment/repo admin access, not
  just a PR approval — appropriate, since misdirecting either one could
  write to (or assume a role scoped to) the wrong environment with no
  PR-visible warning.

## Environment isolation

Each environment is a **separate AWS account**:
- Its own state bucket (created by that account's own `bootstrap/` run).
- Its own GitHub Actions OIDC provider (created by that account's own
  `infra/` apply).
- Its own plan/apply IAM roles, scoped to `24dlong/shared-infrastructure`.

`bootstrap/` stays a single, reusable directory (not one copy per
environment) — it's tooling, not environment-specific infrastructure. You
run it once per new account with that account's own credentials and input
values (see `bootstrap/README.md`).

## How backend & variables are injected per environment

`infra/versions.tf` declares an intentionally **empty** `backend "s3" {}`
block (a Terraform "partial configuration"). The real bucket/key/region are
passed at `terraform init` time via `-backend-config` flags. In CI this is
done through the `TF_CLI_ARGS_init` environment variable (which Terraform
reads automatically and appends to every `terraform init` invocation),
set by the library reusable workflow from that environment's **GitHub
Environment** variables:

```yaml
env:
  TF_CLI_ARGS_init: >-
    -backend-config=bucket=${{ vars.STATE_BUCKET }}
    -backend-config=key=${{ vars.STATE_KEY }}
    -backend-config=region=${{ vars.STATE_REGION }}
    -backend-config=use_lockfile=true
```

Each environment gets its own GitHub Environment (repo Settings →
Environments → e.g. `production`), holding:
- `AWS_ROLE_ARN_PLAN` / `AWS_ROLE_ARN_APPLY` — that environment's OIDC role
  ARNs (already supported today; this is what selects which AWS account a
  job authenticates into).
- `STATE_BUCKET`, `STATE_KEY`, `STATE_REGION` — backend-config values.
- Optionally, required reviewers (useful for upper environments, gating the
  apply job before it runs).

Terraform variable overrides do **not** go here — see
`environments/<env>/terraform.tfvars` below and "Where environment values
live" above.

## The GitOps deployment trigger: `deployed.json`

`environments/<env>/deployed.json` is the **desired-state record** for that
environment — the ref/sha it should currently be running:

```json
{
  "ref": "main",
  "sha": "c0ffee...",
  "requestedAt": "2026-08-09T12:00:00Z",
  "sourceWorkflowRunUrl": "https://github.com/24dlong/shared-infrastructure/actions/runs/123"
}
```

This file is the trigger, not just a log:
- Changing it via a PR triggers `pull-request-deploy.yml`, which runs
  `terraform plan` for `infra/` against that environment.
- Merging that PR triggers `merge-deploy.yml`, which runs `terraform apply`
  — using the existing `terraform/apply@v4` action's built-in behavior of
  looking up the PR that was merged and replaying its saved plan artifact.
  This works because the deployed.json bump is always a real PR.

Whether a deployment actually *succeeded* is visible from that PR's merge
commit's `merge-deploy.yml` run (and from GitHub's own Deployments feature,
populated automatically once a job sets `environment: <name>`). The file
itself is never rewritten after the fact — it always represents "desired",
and CI history represents "actual/status". This avoids a second write (and
a potential retrigger loop) after apply.

### Why per-environment files, not one combined file

`environments/<env>/deployed.json` (one file per environment) rather than a
single combined manifest, so that:
- A path-filter can cleanly trigger only the affected environment's
  plan/apply.
- A future promotion to `staging` never touches `production`'s file (or
  vice versa) — no risk of an unrelated environment being replanned.

### Answering "what's deployed where" / "what needs promoting"

Read (or diff) the `deployed.json` files directly:
- `environments/production/deployed.json` vs `environments/staging/deployed.json`
  tells you at a glance what ref/sha each environment is on.
- `git log <staging.sha>..<production.sha> -- infra/` shows exactly what
  changed in `infra/` between what staging is running and what production is
  running — i.e., what's eligible to promote.

## Standard pipeline vs. deploy pipeline

| Pipeline | Trigger | Does |
| --- | --- | --- |
| `pull-request.yml` | PR to `main` | Quality gate only. No terraform. |
| `merge.yml` | push to `main` | Quality gate, create a version (tag), and — only if `infra/**` changed — open a PR bumping `environments/production/deployed.json` to the new commit. |
| `pull-request-deploy.yml` | PR touching `environments/**/deployed.json` | Thin wrapper that calls the library GitOps deploy workflow with `command: plan`. |
| `merge-deploy.yml` | push to `main` touching `environments/**/deployed.json` | Thin wrapper that calls the library GitOps deploy workflow with `command: apply`. |

This split means routine code review (the standard PR) never runs
terraform, and terraform only ever runs against a change that's explicitly
requesting a deployment via `deployed.json` — a clean audit trail of every
plan/apply, each tied to its own reviewable PR.

### Checking out the pinned sha, not `main` HEAD

A `deployed.json` bump PR is always opened from current `main`, so its tree
(and a merge to `main`) can contain a *newer* `infra/` than the sha the
environment is requesting — especially once promotion to an upper
environment exists and a bump can target an already-released older sha.

The library GitOps deploy workflow therefore:

1. Detects which `environments/<env>/deployed.json` files changed.
2. Reads `.sha` from each (never `.ref`, which is often a moving name like
   `main`).
3. Fans out one job per environment with `environment: <env>` and passes
   that sha as `ref` to `terraform/plan` / `terraform/apply`.
4. Those actions check out that ref so `infra/` matches the requested
   version, not PR/`main` HEAD.

Apply still matches the saved plan via the bump PR's merge commit
(`GITHUB_SHA`) — the Terraform tree ref and the GitHub plan-artifact lookup
are independent.

## Adding a new environment (e.g. `staging`)

1. Create/obtain a new, separate AWS account for `staging`.
2. Run `bootstrap/` once against that account (see `bootstrap/README.md`) to
   create its own state bucket.
3. Add `environments/staging/terraform.tfvars` with the values that differ
   from the `production` defaults (e.g. `name_prefix`, `state_bucket_name`,
   `state_key_prefix`).
4. Run `infra/` once locally against that account (manual first apply, same
   chicken-and-egg reasoning as `production`'s original bootstrap) to create
   its OIDC provider and IAM roles, using
   `terraform apply -var-file=../environments/staging/terraform.tfvars`.
5. In GitHub repo Settings → Environments, create a `staging` Environment
   with its own `AWS_ROLE_ARN_PLAN` / `AWS_ROLE_ARN_APPLY` / `STATE_BUCKET` /
   `STATE_KEY` / `STATE_REGION` (from step 4's outputs). Optionally add
   required reviewers.
6. Add `environments/staging/README.md` (facts) and
   `environments/staging/deployed.json` (seed with the current
   `production` sha, or leave for the first promotion to set).
   The directory name must match the GitHub Environment name. No workflow
   edits: the library GitOps deploy workflow auto-detects the new
   `deployed.json` and passes `-var-file=environments/staging/terraform.tfvars`
   automatically.
7. Build a `promote.yml` workflow (out of scope for this document's current
   revision) that, on release/tag publish, calls the `deployment-pr`
   composite action with `environment: staging` and the released ref. The
   existing deploy workflows will plan/apply that sha's `infra/`, even if
   `main` has since moved on.

No changes to `infra/*.tf` are required to add an environment — that's the
entire point of this design.

## Further/deferred considerations

- **Downstream consumers**: other repos (e.g. those generated by
  `cookiecutter-nextjs-infra`) read this repo's `terraform_remote_state`
  output today assuming a single "production" state path. Once a second
  environment exists, they'll need to become environment-aware (e.g. an
  `environment` input selecting which state key to read). Not solved here.
- **GitHub Environment creation is currently a manual step.** Could be
  automated later (e.g. via the `integrations/github` Terraform provider)
  if the number of environments grows.
- **Automated drift-check**: a scheduled/on-demand workflow that reads all
  `environments/*/deployed.json` files and reports what's pending promotion
  could replace manual inspection once there are 2+ environments.
