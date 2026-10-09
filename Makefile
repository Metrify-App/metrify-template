.DEFAULT_GOAL := help

# Fixed verbs of the Metrify standard (.claude/skills/metrify-sync/STANDARD.md): CI, hooks and agents
# call these. /metrify-setup replaces each stub with the stack's real command.
.PHONY: help install dev format format-check lint typecheck test fix check

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"} /^##@/ {printf "\n  %s\n", substr($$0, 5); next} \
		/^[a-zA-Z0-9_-]+:.*##/ {printf "    %-14s %s\n", $$1, $$2}' $(MAKEFILE_LIST); echo

##@ Standard

install: ## Install dependencies and the git hooks
	npm install --no-fund --no-audit

dev: ## Run the project locally
	@echo "dev: nothing to do"

format: ## Format the code
	@echo "format: nothing to do"

format-check: ## Check formatting
	@echo "format-check: nothing to do"

lint: ## Lint
	@echo "lint: nothing to do"

typecheck: ## Type check
	@echo "typecheck: nothing to do"

test: ## Run the tests
	@echo "test: nothing to do"

fix: format ## Format and apply autofixable lint
	@echo "fix: no autofix lint configured"

check: format-check lint typecheck test ## Everything the CI runs

##@ Project
