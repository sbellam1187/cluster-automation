# Modular Terraform EKS Configuration

This repository contains a production-ready, modular Terraform configuration for deploying AWS EKS clusters.

## Directory Structure

```
terraform/
├── README.md                          # This file
├── __modules/                         # Reusable Terraform modules
│   ├── aws-eks-cluster/              # EKS cluster module
│   │   ├── eks-cluster.tf
│   │   ├── addons.tf
│   │   ├── variables.tf
│   │   ├── output.tf
│   │   └── README.md
│   │
│   ├── aws-subnets/                  # VPC and networking module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── output.tf
│   │   └── README.md
│   │
│   ├── aws-iam-roles/                # IAM role module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── output.tf
│   │
│   ├── aws-iam-policy/               # IAM policy module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── output.tf
│   │
│   └── ...                           # Other modules
│
└── eks-cluster/                       # EKS cluster implementations
    ├── example/                       # Example environment
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   ├── providers.tf
    │   ├── terraform.tfvars.example
    │   └── README.md
    │
    ├── lab/                          # Lab environment (if exists)
    │   └── ...
    │
    └── README.md                      # Implementation guide
```

## Key Features

- **Modular Design**: Reusable modules for VPC, EKS, IAM, etc.
- **Multi-Environment**: Easy to create dev, staging, and production environments
- **Best Practices**: Security, high availability, and cost optimization built-in
- **Extensible**: Easy to add new modules and environments
- **Well-Documented**: Comprehensive README files and examples

## Getting Started

### Option 1: Use Example Configuration (Recommended)

```bash
cd terraform/eks-cluster/example

# Configure cluster
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# Deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Access cluster
eval "$(terraform output -raw configure_kubectl)"
kubectl get nodes
```

### Option 2: Create Your Own Environment

```bash
mkdir -p terraform/eks-cluster/prod

cat > terraform/eks-cluster/prod/main.tf << 'EOF'
module "vpc" {
  source = "../../__modules/aws-subnets"
  
  vpc_name          = "prod-vpc"
  vpc_cidr          = "10.0.0.0/16"
  cluster_name      = "prod-cluster"
}

module "eks_cluster_role" {
  source = "../../__modules/aws-iam-roles"
  
  role_name = "prod-cluster-role"
  # ... configuration ...
}

module "eks_cluster" {
  source = "../../__modules/aws-eks-cluster"
  
  cluster_name = "prod-cluster"
  # ... configuration ...
}
EOF
```

## Available Modules

### aws-subnets
VPC, subnets, Internet Gateway, NAT Gateways, and route tables.

**Location**: `__modules/aws-subnets/`  
**Key Resources**: VPC, subnets, routing, security

### aws-eks-cluster
EKS cluster, OIDC provider, and managed add-ons.

**Location**: `__modules/aws-eks-cluster/`  
**Key Resources**: Cluster, add-ons, logging, OIDC

### aws-iam-roles
Generic IAM role module for creating roles with assume policies.

**Location**: `__modules/aws-iam-roles/`  
**Key Resources**: IAM roles, policy attachments

### aws-iam-policy
Generic IAM policy module for creating policies.

**Location**: `__modules/aws-iam-policy/`  
**Key Resources**: Inline and managed IAM policies

### Other Modules
Additional modules for Vault, CASTAI, service accounts, etc.

**Location**: `__modules/*/`

## Configuration Examples

### Minimal Setup

```hcl
module "vpc" {
  source = "../../__modules/aws-subnets"
  
  vpc_name     = "my-vpc"
  vpc_cidr     = "10.0.0.0/16"
  cluster_name = "my-cluster"
}

module "eks_cluster" {
  source = "../../__modules/aws-eks-cluster"
  
  cluster_name            = "my-cluster"
  cluster_version         = "1.29"
  cluster_role_arn        = module.eks_cluster_role.role_arn
  subnet_ids              = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
  enable_oidc_provider    = true
}
```

### Complete Setup with Node Groups

```hcl
resource "aws_eks_node_group" "general" {
  cluster_name    = module.eks_cluster.cluster_id
  node_group_name = "general"
  node_role_arn   = module.node_role.role_arn
  subnet_ids      = module.vpc.private_subnet_ids
  
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 5
  }
  
  instance_types = ["t3.medium"]
  disk_size      = 50
  capacity_type  = "ON_DEMAND"
  
  labels = {
    role = "general"
  }
}
```

## Supported Environments

The configuration supports creating multiple environments:

- **Development** (`eks-cluster/dev/`) - Cost-optimized, single NAT
- **Staging** (`eks-cluster/staging/`) - Medium-sized, multi-NAT
- **Production** (`eks-cluster/prod/`) - Full HA, monitoring enabled
- **Lab** (`eks-cluster/lab/`) - Testing environment

Each environment can have its own:
- Configuration (`terraform.tfvars`)
- Backend state (S3 or local)
- Variable overrides
- Additional resources

## State Management

### Local Backend (Default for Examples)

```hcl
terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
```

### S3 Backend (Recommended for Production)

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state"
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

Configure in `providers.tf` or `backend.tf`.

## Module Outputs

Access module outputs in your environment configuration:

```hcl
# From vpc module
output "vpc_id" {
  value = module.vpc.vpc_id
}

# From eks module
output "cluster_endpoint" {
  value = module.eks_cluster.cluster_endpoint
}

# From iam module
output "cluster_role_arn" {
  value = module.eks_cluster_role.role_arn
}
```

## Adding New Modules

1. Create directory: `__modules/my-module/`
2. Create files:
   - `main.tf` - Resources
   - `variables.tf` - Input variables
   - `output.tf` - Output values
   - `providers.tf` - Provider requirements
   - `README.md` - Module documentation
3. Reference in environment configuration

Example module structure:

```
__modules/my-module/
├── main.tf
├── variables.tf
├── output.tf
├── providers.tf
└── README.md
```

## Best Practices

### Variable Naming
- Use lowercase with underscores: `cluster_name`
- Use meaningful names: `enable_nat_gateway` vs `nat`

### Output Naming
- Match variable names for consistency
- Use descriptive names: `cluster_endpoint` vs `endpoint`

### Resource Naming
- Use `var.cluster_name` in resource names for consistency
- Example: `"${var.cluster_name}-role"`

### Documentation
- Document all variables in `variables.tf`
- Include examples in README files
- Add comments for complex logic

### State Management
- Use remote state for production (S3 + DynamoDB)
- Enable encryption for state
- Use state locking to prevent concurrent modifications

## Terraform Commands

### Initialize Environment

```bash
cd terraform/eks-cluster/example
terraform init
```

### Validate Configuration

```bash
terraform validate
terraform fmt -recursive -check
```

### Plan Changes

```bash
terraform plan -out=tfplan
```

### Apply Configuration

```bash
terraform apply tfplan
```

### View State

```bash
terraform state list
terraform state show module.eks_cluster
```

### Destroy Resources

```bash
terraform destroy
```

## Troubleshooting

### Module Not Found

Ensure relative paths are correct:
```bash
# From environment directory
ls -la ../../__modules/aws-eks-cluster/
```

### Invalid Provider Configuration

Check `providers.tf` has all required providers:
```bash
terraform init
terraform validate
```

### State Lock Issues

If stuck on state lock, manually unlock (use with caution):
```bash
terraform force-unlock <LOCK_ID>
```

## Advanced Topics

### Workspace Isolation

Use Terraform workspaces for environment isolation:

```bash
terraform workspace new prod
terraform workspace select prod
terraform plan
terraform apply
```

### Variable Overrides

Override variables via command line:

```bash
terraform apply -var="instance_types=[\"t3.large\"]"
```

### Conditional Resources

Use conditionals for optional resources:

```hcl
resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0
  # ...
}
```

### Module Versioning

Pin module versions for stability:

```hcl
module "vpc" {
  source = "../../__modules/aws-subnets"
  # Add version when using external modules
  # source = "git::https://github.com/myorg/modules.git//aws-subnets?ref=v1.0.0"
}
```

## References

- **Terraform AWS Provider**: https://registry.terraform.io/providers/hashicorp/aws/latest
- **AWS EKS Documentation**: https://docs.aws.amazon.com/eks/
- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **Terraform Best Practices**: https://www.terraform.io/docs/language/modules/develop/

## Support

For issues or improvements:

1. Check module README files
2. Review example configurations
3. Consult AWS and Terraform documentation
4. Open an issue in the repository

## License

This configuration is provided as-is for use in AWS environments.

---

**Version**: 1.0  
**Last Updated**: 2026-05-11  
**Terraform Version**: >= 1.0  
**AWS Provider Version**: ~> 5.0
