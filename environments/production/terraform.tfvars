aws_region  = "us-east-2"
name_prefix = "24dlong-shared-infrastructure-prod"

# GitHub has enabled immutable OIDC subject claims for this repo, so these
# embed the org/repo's numeric ID (repo:ORG@ORG_ID/REPO@REPO_ID:...). See
# https://docs.github.com/en/actions/reference/security/oidc#immutable-subject-claims
github_org    = "24dlong@24920691"
github_repo   = "shared-infrastructure@1323258551"
github_branch = "main"

state_bucket_name = "24dlong-shared-infrastructure-prod-terraform-state"
state_key_prefix  = "24dlong-shared-infrastructure/production"

tags = {
  Project     = "24dlong-shared-infrastructure"
  Environment = "production"
  ManagedBy   = "terraform"
}
