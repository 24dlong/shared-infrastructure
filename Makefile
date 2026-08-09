.PHONY: setup-env lint fmt validate checkov

TERRAFORM_DIRS := bootstrap infra

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
