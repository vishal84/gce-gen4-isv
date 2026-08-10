# ==============================================================================
# Multi-Zone Compute Cluster - Terraform Makefile
# ==============================================================================
# Usage:
#   make help         - Display available targets
#   make init         - Initialize Terraform working directory
#   make bootstrap    - Ensure GCS state bucket exists and initialize remote backend
#   make dry-run      - Run Terraform plan in dry-run mode
#   make plan         - Alias for dry-run
#   make deploy       - Apply Terraform deployment (interactive prompt)
#   make apply        - Alias for deploy
#   make deploy-auto  - Apply Terraform deployment automatically (-auto-approve)
#   make validate     - Validate Terraform configuration syntax
#   make fmt          - Format all Terraform HCL files
#   make fmt-check    - Check if HCL files are formatted properly
#   make output       - Show Terraform output variables
#   make refresh      - Refresh Terraform state against cloud resources
#   make destroy      - Tear down deployed infrastructure
#   make clean        - Clean local terraform cache files
# ==============================================================================

# Variables
TF_DIR      ?= terraform
VAR_FILE    ?= config.tfvars
PROJECT_ID  ?= mongo-experiments
BUCKET_NAME ?= mongo-experiments-tfstate
REGION      ?= us-central1

.PHONY: all help init bootstrap plan dry-run deploy apply deploy-auto validate fmt fmt-check output refresh destroy clean

all: help

## help: Display all available Makefile targets with descriptions
help:
	@echo "=============================================================================="
	@echo "                   Terraform Infrastructure Deployment                        "
	@echo "=============================================================================="
	@echo "Usage: make [target]"
	@echo ""
	@echo "Deployment & Execution Targets:"
	@echo "  bootstrap    - Ensure GCS bucket '$(BUCKET_NAME)' exists and initialize backend"
	@echo "  init         - Initialize Terraform working directory and provider plugins"
	@echo "  dry-run      - Perform dry-run execution plan (terraform plan)"
	@echo "  plan         - Alias for dry-run"
	@echo "  deploy       - Deploy infrastructure (terraform apply)"
	@echo "  apply        - Alias for deploy"
	@echo "  deploy-auto  - Deploy infrastructure without confirmation (-auto-approve)"
	@echo "  destroy      - Destroy all provisioned cloud infrastructure"
	@echo ""
	@echo "Maintenance & Quality Targets:"
	@echo "  validate     - Check Terraform configuration syntax and semantics"
	@echo "  fmt          - Automatically format all HCL files"
	@echo "  fmt-check    - Verify HCL formatting without modifying files"
	@echo "  output       - Show Terraform output values (IPs, instance names)"
	@echo "  refresh      - Sync local state with actual infrastructure status"
	@echo "  clean        - Remove local .terraform operational artifacts and cache"
	@echo "=============================================================================="

## bootstrap: Ensure GCS bucket exists and initialize backend state migration
bootstrap:
	@echo "==> Checking if GCS state bucket 'gs://$(BUCKET_NAME)' exists in project '$(PROJECT_ID)'..."
	@if ! gcloud storage buckets describe gs://$(BUCKET_NAME) --project=$(PROJECT_ID) >/dev/null 2>&1; then \
		echo "==> Creating GCS bucket 'gs://$(BUCKET_NAME)' in project '$(PROJECT_ID)'..."; \
		gcloud storage buckets create gs://$(BUCKET_NAME) --project=$(PROJECT_ID) --location=$(REGION) --uniform-bucket-level-access; \
	else \
		echo "==> GCS state bucket 'gs://$(BUCKET_NAME)' already exists."; \
	fi
	@echo "==> Initializing Terraform with remote backend..."
	@cd $(TF_DIR) && terraform init -reconfigure
	@echo "==> Ensuring GCS state bucket is tracked in Terraform state..."
	@if ! cd $(TF_DIR) && terraform state list 2>/dev/null | grep -q "google_storage_bucket.terraform_state"; then \
		echo "==> Importing existing GCS bucket '$(BUCKET_NAME)' into Terraform state..."; \
		cd $(TF_DIR) && terraform import -var-file="$(VAR_FILE)" google_storage_bucket.terraform_state $(BUCKET_NAME); \
	fi

## init: Initialize Terraform working directory
init:
	@echo "==> Initializing Terraform in $(TF_DIR)..."
	@cd $(TF_DIR) && terraform init

## dry-run: Run Terraform execution plan (dry mode)
dry-run: init
	@echo "==> Running Terraform plan (dry mode) using $(VAR_FILE)..."
	@cd $(TF_DIR) && terraform plan -var-file="$(VAR_FILE)"

## plan: Alias for dry-run
plan: dry-run

## deploy: Apply Terraform configuration with interactive confirmation
deploy: init
	@echo "==> Applying Terraform deployment using $(VAR_FILE)..."
	@cd $(TF_DIR) && terraform apply -var-file="$(VAR_FILE)"

## apply: Alias for deploy
apply: deploy

## deploy-auto: Apply Terraform configuration with auto-approval
deploy-auto: init
	@echo "==> Applying Terraform deployment automatically (-auto-approve) using $(VAR_FILE)..."
	@cd $(TF_DIR) && terraform apply -var-file="$(VAR_FILE)" -auto-approve

## validate: Validate Terraform syntax and configuration logic
validate: init
	@echo "==> Validating Terraform files..."
	@cd $(TF_DIR) && terraform validate

## fmt: Format Terraform HCL files
fmt:
	@echo "==> Formatting Terraform files..."
	@cd $(TF_DIR) && terraform fmt -recursive

## fmt-check: Check formatting of Terraform files
fmt-check:
	@echo "==> Checking Terraform code formatting..."
	@cd $(TF_DIR) && terraform fmt -check -recursive

## output: Display output variables from Terraform state
output:
	@echo "==> Fetching Terraform outputs..."
	@cd $(TF_DIR) && terraform output

## refresh: Update local state file with actual infrastructure state
refresh:
	@echo "==> Refreshing Terraform state..."
	@cd $(TF_DIR) && terraform refresh -var-file="$(VAR_FILE)"

## destroy: Destroy all provisioned infrastructure
destroy:
	@echo "==> WARNING: Preparing to destroy infrastructure..."
	@cd $(TF_DIR) && terraform destroy -var-file="$(VAR_FILE)"

## clean: Remove local terraform directories and state backup artifacts
clean:
	@echo "==> Cleaning local Terraform cache and backups..."
	@rm -rf $(TF_DIR)/.terraform
	@rm -f $(TF_DIR)/.terraform.lock.hcl
	@rm -f $(TF_DIR)/terraform.tfstate*
	@echo "==> Clean complete."
