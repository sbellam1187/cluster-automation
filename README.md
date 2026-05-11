# EKS Cluster Automation with Terraform

A comprehensive Terraform configuration for provisioning and managing AWS EKS clusters with production-ready best practices.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [File Structure](#file-structure)
- [Deploying](#deploying)
- [Managing Private Registries](#managing-private-registries)
- [IRSA (IAM Roles for Service Accounts)](#irsa-iam-roles-for-service-accounts)
- [Monitoring and Logging](#monitoring-and-logging)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

## Features

- ✅ **Complete VPC Setup**: Automatically creates VPC, public/private subnets, NAT gateways, and route tables
- ✅ **Multi-AZ Deployment**: Distributed across multiple availability zones for high availability
- ✅ **EKS Cluster**: Latest Kubernetes with configurable version management
- ✅ **Managed Node Groups**: Easy scaling with multiple node group configurations
- ✅ **OIDC Provider**: IRSA support for fine-grained IAM permissions per service account
- ✅ **Security Best Practices**: IMDSv2, security groups, and least-privilege IAM roles
- ✅ **Private Container Registry Support**: Built-in support for enterprise registries (no ECR dependency)
- ✅ **EKS Add-ons**: VPC CNI, CoreDNS, kube-proxy, EBS/EFS CSI drivers
- ✅ **CloudWatch Logging**: Integrated cluster logging with configurable retention
- ✅ **Systems Manager Access**: SSM session manager for secure node access
- ✅ **Monitoring Ready**: Container Insights and VPC Flow Logs support

## Prerequisites

1. **AWS Account**: Valid AWS account with appropriate permissions
2. **Terraform**: Version 1.0 or later
3. **AWS CLI**: Configured with appropriate credentials
4. **kubectl**: Installed and configured
5. **Helm** (optional): For deploying additional applications

### AWS Permissions

The IAM user/role executing Terraform needs the following permissions:
- EC2 (VPC, subnets, security groups, NAT gateways)
- EKS (cluster, node groups, add-ons)
- IAM (roles, policies, OIDC providers)
- CloudWatch (log groups)
- Secrets Manager (for private registry credentials)
- Systems Manager (SSM parameters)

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      AWS Account                             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                   VPC (10.0.0.0/16)                  │   │
│  ├──────────────────────────────────────────────────────┤   │
│  │  ┌─────────────┐    ┌─────────────┐   ┌──────────┐ │   │
│  │  │ Public Subnet│    │Public Subnet│   │IGW/NAT   │ │   │
│  │  │ AZ-1         │    │ AZ-2        │   │Gateways  │ │   │
│  │  └─────────────┘    └─────────────┘   └──────────┘ │   │
│  │         ↓                  ↓                          │   │
│  │  ┌─────────────┐    ┌─────────────┐   ┌──────────┐ │   │
│  │  │Private Subnet│   │Private Subnet│   │NATGW    │ │   │
│  │  │ AZ-1         │   │ AZ-2        │   │(optional)│ │   │
│  │  └─────────────┘   └─────────────┘   └──────────┘ │   │
│  │         ↓               ↓                            │   │
│  │    ┌──────────────────────────┐                    │   │
│  │    │  EKS Cluster Control    │                    │   │
│  │    │  Plane                   │                    │   │
│  │    └──────────────────────────┘                    │   │
│  │         ↓               ↓                            │   │
│  │  ┌──────────────┐  ┌──────────────┐               │   │
│  │  │  Node Group  │  │  Node Group  │               │   │
│  │  │  (General)   │  │  (Spot/Compute)             │   │
│  │  └──────────────┘  └──────────────┘               │   │
│  │                                                     │   │
│  └──────────────────────────────────────────────────┘   │
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │          OIDC Provider (for IRSA)               │   │
│  │     ServiceAccount → IAM Role Mapping           │   │
│  └──────────────────────────────────────────────────┘   │
│                                                           │
│  ┌──────────────────────────────────────────────────┐   │
│  │  CloudWatch Log Groups for:                      │   │
│  │  - EKS Control Plane Logs                        │   │
│  │  - VPC Flow Logs (optional)                      │   │
│  │  - Application Logs                              │   │
│  └──────────────────────────────────────────────────┘   │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## Quick Start

### 1. Clone and Initialize

```bash
cd /Users/134951/development/cluster-automation
cp terraform.tfvars.example terraform.tfvars
```

### 2. Edit Configuration

```bash
# Edit terraform.tfvars with your desired settings
vim terraform.tfvars
```

### 3. Configure S3 Backend

Update `backend.tf` with your S3 bucket details:

```hcl
backend "s3" {
  bucket         = "your-terraform-state-bucket"
  key            = "eks/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Plan and Apply

```bash
# Review the plan
terraform plan -out=tfplan

# Apply the configuration
terraform apply tfplan
```

### 6. Configure kubectl

```bash
# Get the kubeconfig command from outputs
terraform output configure_kubectl

# Execute the command to update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Verify cluster access
kubectl get nodes
kubectl get pods -A
```

## Configuration

### Core Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `us-east-1` | AWS region for resources |
| `environment` | string | - | Environment name (dev/staging/prod) |
| `project_name` | string | - | Project name for tagging |
| `cluster_name` | string | - | EKS cluster name |
| `vpc_cidr` | string | `10.0.0.0/16` | VPC CIDR block |
| `cluster_version` | string | `1.29` | Kubernetes version |

### VPC Configuration

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `private_subnet_cidrs` | list(string) | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` | Private subnet CIDR blocks |
| `public_subnet_cidrs` | list(string) | `["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]` | Public subnet CIDR blocks |
| `enable_nat_gateway` | bool | `true` | Enable NAT Gateway |
| `single_nat_gateway` | bool | `false` | Use single NAT (cost optimization) |

### Node Groups Configuration

Configure multiple node groups with different instance types and sizes:

```hcl
node_groups = {
  general = {
    desired_size   = 2
    min_size       = 1
    max_size       = 5
    instance_types = ["t3.medium"]
    disk_size      = 50
    capacity_type  = "ON_DEMAND"
    labels = {
      role = "general"
    }
  }
  spot = {
    desired_size   = 1
    min_size       = 0
    max_size       = 3
    instance_types = ["t3.medium", "t3a.medium"]
    disk_size      = 50
    capacity_type  = "SPOT"
    labels = {
      role = "compute"
    }
    taints = [{
      key    = "workload"
      value  = "spot"
      effect = "NoSchedule"
    }]
  }
}
```

### Private Container Registry

To use a private container registry (Azure ACR, DockerHub Private, etc.):

```hcl
enable_ecr_access            = false  # Don't use AWS ECR
private_registry_url         = "myregistry.azurecr.io"
private_registry_username    = "username"
private_registry_password    = "token_or_password"
private_registry_email       = "user@example.com"
```

The configuration automatically creates Kubernetes secrets for image pulling.

### Security Configuration

```hcl
enable_imds_v2                       = true      # Enforce IMDSv2
enable_ssm_access                    = true      # SSM Session Manager
cluster_endpoint_private_access      = true      # Private API endpoint
cluster_endpoint_public_access       = true      # Public API endpoint
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # Restrict this!
```

## File Structure

```
cluster-automation/
├── backend.tf              # Terraform state backend configuration
├── variables.tf            # Input variables with validation
├── outputs.tf              # Output values
├── data.tf                 # AWS data sources
├── vpc.tf                  # VPC, subnets, NAT gateways
├── iam.tf                  # IAM roles and policies
├── eks.tf                  # EKS cluster, node groups, OIDC
├── private_registry.tf     # Private registry credential management
├── user_data.sh           # Node initialization script
├── terraform.tfvars.example # Example configuration
└── README.md              # This file
```

### Key File Descriptions

- **backend.tf**: Configures remote state storage in S3 with DynamoDB locking
- **variables.tf**: Defines all input variables with validation rules
- **outputs.tf**: Exports important values like cluster endpoint, node role ARNs
- **data.tf**: Queries AWS for existing data (AZs, AMIs, account info)
- **vpc.tf**: Complete networking setup with public/private subnets
- **iam.tf**: Cluster, node, and addon IAM roles with policies
- **eks.tf**: EKS cluster, node groups, OIDC provider, and add-ons
- **private_registry.tf**: Kubernetes secrets and AWS Secrets Manager integration

## Deploying

### Initial Deployment

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format code (optional)
terraform fmt -recursive

# Plan the deployment
terraform plan -out=tfplan

# Apply the configuration
terraform apply tfplan
```

### Deployment Time

Initial deployment typically takes **15-20 minutes**:
- VPC creation: ~2 minutes
- EKS cluster creation: ~10-12 minutes
- Node group provisioning: ~5-8 minutes

### Updating Configuration

```bash
# Make changes to terraform.tfvars
vim terraform.tfvars

# Plan the changes
terraform plan -out=tfplan

# Review the plan carefully
# Apply changes
terraform apply tfplan
```

### Destroying the Cluster

```bash
# Remove applications first
kubectl delete namespace --all --ignore-not-found

# Destroy infrastructure
terraform destroy
```

## Managing Private Registries

### Azure Container Registry (ACR)

```hcl
private_registry_url      = "myregistry.azurecr.io"
private_registry_username = "00000000-0000-0000-0000-000000000000"
private_registry_password = "<access-token>"  # Use service principal password
private_registry_email    = "your@email.com"
```

### Docker Hub Private

```hcl
private_registry_url      = "docker.io"
private_registry_username = "your_username"
private_registry_password = "your_token_or_password"
private_registry_email    = "your@email.com"
```

### Accessing from Pods

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example
spec:
  imagePullSecrets:
  - name: private-registry-secret
  containers:
  - name: app
    image: myregistry.azurecr.io/myimage:latest
```

The Terraform automatically creates two secrets:
- `private-registry-credentials`: In default namespace
- `private-registry-secret`: Docker config format for all namespaces

## IRSA (IAM Roles for Service Accounts)

IRSA allows Kubernetes service accounts to assume IAM roles for fine-grained access control.

### Enabling IRSA

Ensure `enable_oidc_provider = true` in your configuration.

### Example: Pod with S3 Access

1. Create an IAM policy:

```bash
cat > s3-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::my-bucket",
        "arn:aws:s3:::my-bucket/*"
      ]
    }
  ]
}
EOF

# Create IAM policy
aws iam create-policy --policy-name eks-s3-access \
  --policy-document file://s3-policy.json
```

2. Create service account and role (using a separate Terraform or Helm chart):

```bash
# Get the OIDC provider URL from Terraform outputs
OIDC_URL=$(terraform output -raw oidc_provider_url)
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
CLUSTER_NAME="my-eks-cluster"

# Create service account in Kubernetes
kubectl create serviceaccount my-app-sa -n default

# Create IAM role with IRSA trust policy
cat > trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${AWS_ACCOUNT}:oidc-provider/${OIDC_URL#https://}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${OIDC_URL#https://}:sub": "system:serviceaccount:default:my-app-sa",
          "${OIDC_URL#https://}:aud": "sts.amazonaws.com"
        }
      }
    }
  ]
}
EOF

aws iam create-role --role-name eks-app-role \
  --assume-role-policy-document file://trust-policy.json

# Attach policies
aws iam attach-role-policy --role-name eks-app-role \
  --policy-arn arn:aws:iam::${AWS_ACCOUNT}:policy/eks-s3-access

# Annotate service account
kubectl annotate serviceaccount my-app-sa \
  -n default \
  eks.amazonaws.com/role-arn=arn:aws:iam::${AWS_ACCOUNT}:role/eks-app-role
```

3. Deploy pod using the service account:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
  namespace: default
spec:
  serviceAccountName: my-app-sa
  containers:
  - name: app
    image: my-app:latest
    env:
    - name: AWS_ROLE_ARN
      value: arn:aws:iam::ACCOUNT_ID:role/eks-app-role
    - name: AWS_WEB_IDENTITY_TOKEN_FILE
      value: /var/run/secrets/eks.amazonaws.com/serviceaccount/token
```

## Monitoring and Logging

### CloudWatch Logs

EKS cluster logs are automatically sent to CloudWatch:

```bash
# View cluster logs
aws logs tail /aws/eks/my-eks-cluster/cluster --follow

# Specific log stream (e.g., API server logs)
aws logs tail /aws/eks/my-eks-cluster/cluster --log-stream-name-prefix api --follow
```

### Container Insights

Enable monitoring in terraform.tfvars:

```hcl
enable_monitoring = true
```

### VPC Flow Logs

Track network traffic to and from resources:

```hcl
enable_monitoring = true
```

## Troubleshooting

### Cluster Access Issues

```bash
# Verify cluster connectivity
kubectl cluster-info
kubectl get nodes

# Check kubeconfig
cat ~/.kube/config | grep -A 10 "my-eks-cluster"

# Update kubeconfig if needed
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
```

### Node Issues

```bash
# Check node status
kubectl get nodes
kubectl describe node <node-name>

# Check node logs via SSM
aws ssm start-session --target <instance-id>
tail -f /var/log/messages
```

### Pod Networking Issues

```bash
# Verify VPC CNI plugin
kubectl get daemonset -n kube-system aws-node

# Check node security groups
aws ec2 describe-security-groups --filters Name=tag:Name,Values=my-eks-cluster-node-sg

# Verify subnet routes
aws ec2 describe-route-tables --filters Name=vpc-id,Values=<vpc-id>
```

### OIDC Provider Issues

```bash
# Verify OIDC provider
aws iam list-open-id-connect-providers

# Check service account token
kubectl describe serviceaccount <sa-name> -n <namespace>
```

### Addon Installation Failures

```bash
# Check addon status
aws eks describe-addon --cluster-name my-eks-cluster --addon-name vpc-cni

# View addon logs
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-node --tail=50
```

## Cost Optimization Tips

1. **Use Spot Instances**: Configure spot instance node groups for non-critical workloads
2. **Single NAT Gateway**: Set `single_nat_gateway = true` in dev environments
3. **Right-sizing**: Adjust node group instance types based on actual workload needs
4. **Auto-scaling**: Use Cluster Autoscaler or Karpenter for dynamic scaling
5. **Log Retention**: Reduce `cluster_log_retention_in_days` if not needed for long-term analysis
6. **Scheduled Scaling**: Scale down nodes during off-hours for dev/test environments

## Contributing

To contribute improvements:

1. Test changes thoroughly in a dev environment
2. Follow Terraform best practices
3. Update documentation for any new variables
4. Maintain backward compatibility when possible
5. Add appropriate tags and comments

## Support

For issues, questions, or improvements:

1. Check the [Troubleshooting](#troubleshooting) section
2. Review [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
3. Check [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## License

This Terraform configuration is provided as-is for use in your AWS environment.

## Additional Resources

- [AWS EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS EKS Workshop](https://www.eksworkshop.com/)
- [Kubernetes Official Documentation](https://kubernetes.io/docs/)

---

**Last Updated**: 2026-05-11
**Terraform Version**: >= 1.0
**AWS Provider Version**: ~> 5.0