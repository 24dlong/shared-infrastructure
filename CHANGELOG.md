## 0.1.0 (2026-08-18)


- refactor: migrate to single infra directory structure (#15)
- * refactor: migrate to single infra directory structure
- * ci: tweak job names
- chore(deps): update terraform github.com/24dlong/terraform-modules-library to v0.3.1 (#14)
- Co-authored-by: 24dlong-renovate[bot] <286791535+24dlong-renovate[bot]@users.noreply.github.com>
- chore(deps): update dependency checkov to v3.3.9 (#13)
- Co-authored-by: 24dlong-renovate[bot] <286791535+24dlong-renovate[bot]@users.noreply.github.com>
- chore(deps): update 24dlong/github-actions-library action to v4 (#11)
- Co-authored-by: 24dlong-renovate[bot] <286791535+24dlong-renovate[bot]@users.noreply.github.com>
- chore(deps): update terraform aws to v6 (#9)
- Co-authored-by: 24dlong-renovate[bot] <286791535+24dlong-renovate[bot]@users.noreply.github.com>
Co-authored-by: Daniel Long <24.daniel.long@gmail.com>
- feat: publish foundation output contract (state+OIDC) (#10)
- Adds a tags output and documents the terraform_remote_state consumption
pattern in the README, so app-infra repos read the state bucket name,
region, and OIDC provider ARN dynamically instead of hardcoding them.
- Domain/ACM outputs will be appended additively once task 9 (Route 53/ACM
adoption) lands.
- chore(deps): update actions/checkout action to v7 (#4)
- Co-authored-by: 24dlong-renovate[bot] <286791535+24dlong-renovate[bot]@users.noreply.github.com>
- chore(deps): update dorny/paths-filter action to v4 (#8)
- Co-authored-by: 24dlong-renovate[bot] <286791535+24dlong-renovate[bot]@users.noreply.github.com>
- chore(deps): update minor-updates (#3)
- Co-authored-by: 24dlong-renovate[bot] <286791535+24dlong-renovate[bot]@users.noreply.github.com>
- ci: use PAT instead of GITHUB_TOKEN in merge workflow (#6)
- fix: add a missing checkout to workflows (#1)
- fix: fix repository variables (#2)
- feat: add github oidc provider
