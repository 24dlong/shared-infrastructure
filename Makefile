.PHONY: setup-env lint fmt validate checkov init plan apply output

TERRAFORM_DIRS := bootstrap infra
INFRA_DIR := infra
ENV ?=
VAR_FILE := $(CURDIR)/environments/$(ENV)/terraform.tfvars
TF := mise exec -- terraform

setup-env:
	command -v mise >/dev/null 2>&1 || curl https://mise.run | sh
	mise install
	mise exec -- pre-commit install
	mise exec -- pre-commit install --hook-type commit-msg

lint:
	mise exec -- pre-commit run --all-files

fmt:
	@for dir in $(TERRAFORM_DIRS); do \
		echo "terraform fmt $$dir"; \
		(cd $$dir && terraform fmt -recursive); \
	done

validate:
	@for dir in $(TERRAFORM_DIRS); do \
		echo "terraform validate $$dir"; \
		(cd $$dir && terraform init -backend=false -input=false >/dev/null && terraform validate); \
	done

checkov:
	checkov -d bootstrap -d infra --config-file .checkov.yaml

init:
	@if [ -z "$(ENV)" ]; then \
		echo "ENV is required (e.g. make plan ENV=production)" >&2; \
		exit 1; \
	fi
	@if [ ! -f "$(VAR_FILE)" ]; then \
		echo "Unknown environment '$(ENV)': missing $(VAR_FILE)" >&2; \
		exit 1; \
	fi
	@bucket=$$(sed -nE 's/^[[:space:]]*state_bucket_name[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$(VAR_FILE)"); \
	region=$$(sed -nE 's/^[[:space:]]*aws_region[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$(VAR_FILE)"); \
	prefix=$$(sed -nE 's/^[[:space:]]*state_key_prefix[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$(VAR_FILE)"); \
	if [ -z "$$bucket" ] || [ -z "$$region" ] || [ -z "$$prefix" ]; then \
		echo "Failed to parse state_bucket_name, aws_region, or state_key_prefix from $(VAR_FILE)" >&2; \
		exit 1; \
	fi; \
	$(TF) -chdir=$(INFRA_DIR) init -input=false -reconfigure \
		-backend-config="bucket=$$bucket" \
		-backend-config="key=$$prefix/terraform.tfstate" \
		-backend-config="region=$$region" \
		-backend-config="use_lockfile=true"

plan: init
	$(TF) -chdir=$(INFRA_DIR) plan -input=false -var-file="$(VAR_FILE)" $(TF_FLAGS)

apply: init
	$(TF) -chdir=$(INFRA_DIR) apply -input=false -var-file="$(VAR_FILE)" $(TF_FLAGS)

output: init
	$(TF) -chdir=$(INFRA_DIR) output $(TF_FLAGS)
