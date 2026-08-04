# shared-infrastructure

Shared AWS foundation for the Next.js infrastructure initiative.

This repository currently manages only:

- Terraform remote state bucket bootstrap
- GitHub Actions OIDC provider
- Repo-scoped IAM roles for plan/apply

## Layout

- `bootstrap/`: one-time creation of the shared S3 state bucket.
- `production/`: persistent shared foundation resources (OIDC provider and IAM roles).
