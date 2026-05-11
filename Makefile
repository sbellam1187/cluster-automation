.PHONY: help init validate plan apply destroy clean fmt logs kubeconfig test-cluster

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# Variables
TERRAFORM := terraform
TF_PLAN := tfplan
CLUSTER_NAME := $(shell $(TERRAFORM) output -raw cluster_name 2>/dev/null || echo "")
AWS_REGION := $(shell $(TERRAFORM) output -raw aws_region 2>/dev/null || echo "us-east-1")

help: ## Display this help screen
	@grep -h -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(BLUE)%-20s$(NC) %s\n", $$1, $$2}'

init: ## Initialize Terraform
	@echo "$(BLUE)Initializing Terraform...$(NC)"
	$(TERRAFORM) init

validate: ## Validate Terraform configuration
	@echo "$(BLUE)Validating Terraform configuration...$(NC)"
	$(TERRAFORM) validate
	@echo "$(GREEN)✓ Configuration is valid$(NC)"

fmt: ## Format Terraform code
	@echo "$(BLUE)Formatting Terraform code...$(NC)"
	$(TERRAFORM) fmt -recursive
	@echo "$(GREEN)✓ Code formatted$(NC)"

fmt-check: ## Check if Terraform code needs formatting
	@echo "$(BLUE)Checking Terraform code format...$(NC)"
	@if $(TERRAFORM) fmt -recursive -check; then \
		echo "$(GREEN)✓ Code is properly formatted$(NC)"; \
	else \
		echo "$(RED)✗ Code needs formatting - run 'make fmt'$(NC)"; \
		exit 1; \
	fi

plan: validate fmt ## Create Terraform plan
	@echo "$(BLUE)Creating Terraform plan...$(NC)"
	$(TERRAFORM) plan -out=$(TF_PLAN)
	@echo "$(YELLOW)Plan saved to $(TF_PLAN)$(NC)"
	@echo "$(YELLOW)Review with: terraform show $(TF_PLAN)$(NC)"

apply: ## Apply Terraform configuration
	@echo "$(RED)WARNING: This will create/modify AWS resources!$(NC)"
	@echo "$(YELLOW)Press Ctrl+C to cancel, or wait 5 seconds to continue...$(NC)"
	@sleep 5
	@if [ -f "$(TF_PLAN)" ]; then \
		echo "$(BLUE)Applying from saved plan...$(NC)"; \
		$(TERRAFORM) apply $(TF_PLAN); \
		rm $(TF_PLAN); \
	else \
		echo "$(YELLOW)No plan file found. Run 'make plan' first.$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ Deployment complete$(NC)"
	@echo "$(YELLOW)Run 'make kubeconfig' to configure kubectl$(NC)"

destroy: ## Destroy all infrastructure
	@echo "$(RED)!!! WARNING: This will DELETE all AWS resources !!!$(NC)"
	@echo "$(RED)This action cannot be undone!$(NC)"
	@echo "$(YELLOW)Type 'yes' to confirm destruction:$(NC)"
	@read confirm; \
	if [ "$$confirm" = "yes" ]; then \
		$(TERRAFORM) destroy; \
	else \
		echo "$(GREEN)Destruction cancelled$(NC)"; \
	fi

clean: ## Clean up local Terraform files
	@echo "$(BLUE)Cleaning local Terraform files...$(NC)"
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	rm -f tfplan tfplan.json
	rm -f terraform.tfstate*
	rm -f .DS_Store
	@echo "$(GREEN)✓ Cleanup complete$(NC)"

kubeconfig: ## Configure kubectl to access the cluster
	@if [ -z "$(CLUSTER_NAME)" ]; then \
		echo "$(RED)✗ Cluster not yet deployed. Run 'make apply' first.$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Configuring kubectl for cluster: $(CLUSTER_NAME)...$(NC)"
	aws eks update-kubeconfig --region $(AWS_REGION) --name $(CLUSTER_NAME)
	@echo "$(GREEN)✓ kubeconfig updated$(NC)"
	@echo "$(YELLOW)Cluster context: $(shell kubectl config current-context)$(NC)"

test-cluster: kubeconfig ## Test cluster connectivity
	@echo "$(BLUE)Testing cluster connectivity...$(NC)"
	@echo "$(YELLOW)Cluster info:$(NC)"
	kubectl cluster-info
	@echo "$(YELLOW)Nodes:$(NC)"
	kubectl get nodes
	@echo "$(YELLOW)System pods:$(NC)"
	kubectl get pods -n kube-system
	@echo "$(GREEN)✓ Cluster is accessible$(NC)"

logs: ## Tail EKS cluster logs
	@if [ -z "$(CLUSTER_NAME)" ]; then \
		echo "$(RED)✗ Cluster not found. Run 'make apply' first.$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Tailing logs for cluster: $(CLUSTER_NAME)...$(NC)"
	aws logs tail /aws/eks/$(CLUSTER_NAME)/cluster --follow

output: ## Show Terraform outputs
	@echo "$(BLUE)Terraform Outputs:$(NC)"
	$(TERRAFORM) output

output-json: ## Show Terraform outputs as JSON
	@echo "$(BLUE)Terraform Outputs (JSON):$(NC)"
	$(TERRAFORM) output -json

state-list: ## List resources in Terraform state
	@echo "$(BLUE)Resources in Terraform state:$(NC)"
	$(TERRAFORM) state list

state-show: ## Show details of a specific resource (usage: make state-show RESOURCE=aws_eks_cluster.main)
	@if [ -z "$(RESOURCE)" ]; then \
		echo "$(RED)✗ Please specify resource: make state-show RESOURCE=<resource>$(NC)"; \
		exit 1; \
	fi
	$(TERRAFORM) state show $(RESOURCE)

refresh: ## Refresh Terraform state
	@echo "$(BLUE)Refreshing Terraform state...$(NC)"
	$(TERRAFORM) refresh
	@echo "$(GREEN)✓ State refreshed$(NC)"

cost: ## Estimate infrastructure costs (requires terraform-cost-estimation)
	@echo "$(BLUE)Estimating infrastructure costs...$(NC)"
	@echo "$(YELLOW)Install terraformer or terraform-cost-estimation for accurate estimates$(NC)"
	@echo "$(YELLOW)Or use AWS Cost Explorer: https://console.aws.amazon.com/cost-management$(NC)"

security-check: ## Run security checks on Terraform code
	@echo "$(BLUE)Running security checks...$(NC)"
	@echo "$(YELLOW)Install tfsec for comprehensive security scanning$(NC)"
	@echo "$(YELLOW)Run: brew install tfsec && tfsec .$(NC)"

docs: ## Generate documentation
	@echo "$(BLUE)Documentation:$(NC)"
	@echo "  README.md - Full documentation"
	@echo "  DEPLOYMENT.md - Step-by-step deployment guide"
	@echo "  Variables and outputs are defined in:"
	@echo "    - variables.tf"
	@echo "    - outputs.tf"

graph: ## Generate resource graph (requires graphviz)
	@echo "$(BLUE)Generating resource graph...$(NC)"
	$(TERRAFORM) graph > graph.dot
	@echo "$(GREEN)✓ Graph saved to graph.dot$(NC)"
	@echo "$(YELLOW)View with: dot -Tsvg graph.dot -o graph.svg$(NC)"

metrics: ## Show cluster metrics
	@if [ -z "$(CLUSTER_NAME)" ]; then \
		echo "$(RED)✗ Cluster not found. Run 'make apply' first.$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Cluster Metrics:$(NC)"
	@echo "$(YELLOW)Nodes:$(NC)"
	@kubectl get nodes -o wide 2>/dev/null || echo "kubectl not configured"
	@echo "$(YELLOW)Node Resource Usage:$(NC)"
	@kubectl top nodes 2>/dev/null || echo "Metrics server not available"
	@echo "$(YELLOW)Pod Resource Usage:$(NC)"
	@kubectl top pods -A 2>/dev/null || echo "Metrics server not available"

addons: ## List EKS add-ons
	@if [ -z "$(CLUSTER_NAME)" ]; then \
		echo "$(RED)✗ Cluster not found. Run 'make apply' first.$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)EKS Add-ons:$(NC)"
	aws eks list-addons --cluster-name $(CLUSTER_NAME) --region $(AWS_REGION)

health: ## Check cluster health
	@echo "$(BLUE)Cluster Health Check:$(NC)"
	@echo "$(YELLOW)API Server:$(NC)"
	@kubectl get --raw /healthz 2>/dev/null && echo "✓ Healthy" || echo "✗ Not responding"
	@echo "$(YELLOW)System Components:$(NC)"
	@kubectl get pods -n kube-system -o wide
	@echo "$(YELLOW)Nodes:$(NC)"
	@kubectl get nodes -o wide

backup: ## Backup Terraform state
	@echo "$(BLUE)Backing up Terraform state...$(NC)"
	@mkdir -p backups
	@cp terraform.tfstate backups/terraform.tfstate.$(shell date +%Y%m%d_%H%M%S) 2>/dev/null || echo "No state file to backup"
	@$(TERRAFORM) state pull > backups/terraform-state-$(shell date +%Y%m%d_%H%M%S).json
	@echo "$(GREEN)✓ Backup complete$(NC)"

.PHONY: help init validate plan apply destroy clean kubeconfig test-cluster logs output state-list refresh cost security-check docs graph metrics addons health backup

# Default target
.DEFAULT_GOAL := help
