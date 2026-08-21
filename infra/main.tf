provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "planner" {
  statement {
    sid    = "StateBucketRead"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${var.state_bucket_name}"
    ]
  }

  statement {
    sid    = "StateObjectRead"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${var.state_bucket_name}/${var.state_key_prefix}/*"
    ]
  }

  statement {
    sid    = "ReadIamOidcProvider"
    effect = "Allow"
    actions = [
      "iam:GetOpenIDConnectProvider"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
    ]
  }

  statement {
    sid    = "ReadIamRole"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:GetRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.name_prefix}-github-oidc-role",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.name_prefix}-plan-github-oidc-role"
    ]
  }

  #checkov:skip=CKV_AWS_356: iam:ListOpenIDConnectProviders is an account-level list action with no resource-level ARN support.
  statement {
    sid    = "ListIamOidcProviders"
    effect = "Allow"
    actions = [
      "iam:ListOpenIDConnectProviders"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "deployer" {
  statement {
    sid    = "StateBucketList"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${var.state_bucket_name}"
    ]
  }

  statement {
    sid    = "StateObjectReadWrite"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::${var.state_bucket_name}/${var.state_key_prefix}/*"
    ]
  }

  statement {
    sid    = "ManageGithubOidcProvider"
    effect = "Allow"
    actions = [
      "iam:CreateOpenIDConnectProvider",
      "iam:DeleteOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
    ]
  }

  #checkov:skip=CKV_AWS_356: iam:ListOpenIDConnectProviders is an account-level list action with no resource-level ARN support.
  statement {
    sid    = "ListGithubOidcProviders"
    effect = "Allow"
    actions = [
      "iam:ListOpenIDConnectProviders"
    ]
    resources = ["*"]
  }

  #checkov:skip=CKV_AWS_109: role management actions are already scoped to two named role ARNs below; broader IAM permission management is not granted.
  statement {
    sid    = "ManageGithubOidcRole"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",
      "iam:PutRolePolicy",
      "iam:DeleteRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:GetRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.name_prefix}-github-oidc-role",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.name_prefix}-plan-github-oidc-role"
    ]
  }
}

module "github_oidc" {
  source = "git::https://github.com/24dlong/terraform-modules-library.git//modules/github-oidc?ref=0.4.0"

  name_prefix = var.name_prefix

  create_oidc_provider = true
  github_org           = "24dlong@24920691"
  github_repo          = "shared-infrastructure@1323258551"
  # terraform-deploy.yml sets environment: <env> on the apply job, so GitHub
  # puts environment:<name> in the OIDC sub (not the branch ref). Restrict
  # which branches can use that Environment with GitHub Environment
  # deployment branch rules.
  github_environment = var.environment

  inline_policy_json  = data.aws_iam_policy_document.deployer.json
  managed_policy_arns = []

  tags = var.tags
}

module "github_oidc_plan" {
  source = "git::https://github.com/24dlong/terraform-modules-library.git//modules/github-oidc?ref=0.4.0"

  name_prefix = "${var.name_prefix}-plan"

  create_oidc_provider     = false
  github_oidc_provider_arn = module.github_oidc.oidc_provider_arn
  github_org               = "24dlong@24920691"
  github_repo              = "shared-infrastructure@1323258551"
  github_environment       = var.environment

  inline_policy_json  = data.aws_iam_policy_document.planner.json
  managed_policy_arns = []

  tags = var.tags
}
