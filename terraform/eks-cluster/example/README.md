# EKS Cluster Modular Configuration - Example Guide

This example demonstrates how to use the modular EKS Terraform configuration to deploy a complete, production-ready EKS cluster with all required components.

## Overview

The configuration uses reusable modules from `terraform/__modules/` to create:

- **VPC**: Multi-AZ VPC with public/private subnets, NAT Gateways, and routing
- **EKS Cluster**: Managed Kubernetes cluster with configured add-ons
- **IAM Roles**: Cluster, node, and IRSA service account roles
- **Node Groups**: Managed groups with auto-scaling and custom labels
- **Private Registry**: Support for enterprise container registries
- **Monitoring**: CloudWatch logging and OIDC provider for IRSA

## Quick Start

### Prerequisites

```bash
# Verify requirements
terraform version   # >= 1.0
aws --version      # >= 2.0
kubectl version    # Latest
```

### Step 1: Configure

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit configuration
vim terraform.tfvars

# Key values to update:
# - cluster_name
# - environment
# - aws_region
# - Optional: private registry settings
```

### Step 2: Initialize

```bash
terraform init
```

### Step 3: Review Plan

```bash
terraform plan -out=tfplan
terraform show tfplan | head -100
```

### Step 4: Deploy

```bash
terraform apply tfplan
```

This will create:
- 1 VPC with 3 public & 3 private subnets
- 1 EKS cluster
- 2-5 EC2 worker nodes
- NAT Gateways (1-3 depending on single_nat_gateway setting)
- Security groups, route tables, and IAM roles

**Estimated deployment time**: 15-20 minutes

### Step 5: Access Cluster

```bash
# Configure kubectl
eval "$(terraform output -raw configure_kubectl)"

# Verify access
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

## Configuration Examples

### Minimal Development Environment

```hcl
# terraform.tfvars
cluster_name        = "dev-cluster"
environment         = "dev"
aws_region          = "us-east-1"
single_nat_gateway  = true
kubernetes_version  = "1.29"

node_groups = {
  general = {
    desired_size   = 1
    min_size       = 1
    max_size       = 3
    instance_types = ["t3.small"]
    disk_size      = 30
    capacity_type  = "SPOT"
  }
}
```

### Production Environment with HA

```hcl
# terraform.tfvars
cluster_name        = "prod-cluster"
environment         = "prod"
aws_region          = "us-east-1"
single_nat_gateway  = false  # HA NAT
kubernetes_version  = "1.29"

node_groups = {
  general = {
    desired_size   = 3
    min_size       = 3
    max_size       = 10
    instance_types = ["t3.large"]
    disk_size      = 100
    capacity_type  = "ON_DEMAND"
  }
  
  compute = {
    desired_size   = 2
    min_size       = 0
    max_size       = 5
    instance_types = ["t3.xlarge"]
    disk_size      = 100
    capacity_type  = "SPOT"
    labels = {
      role = "compute"
    }
  }
}
```

### With Private Container Registry

```hcl
# terraform.tfvars
enable_private_registry    = true
private_registry_url       = "myregistry.azurecr.io"
private_registry_username  = "username"
private_registry_password  = "token_or_password"
private_registry_email     = "user@example.com"

# Then pods can use:
# imagePullSecrets:
# - name: private-registry-credentials
```

## Module Structure

### aws-subnets Module

Creates networking infrastructure:

**Variables:**
- `vpc_cidr`: VPC CIDR block
- `private_subnet_cidrs`: Private subnet CIDRs
- `public_subnet_cidrs`: Public subnet CIDRs
- `enable_nat_gateway`: Enable NAT Gateways
- `single_nat_gateway`: Use single NAT (cost saving)

**Outputs:**
- `vpc_id`: VPC ID
- `private_subnet_ids`: Private subnet IDs
- `public_subnet_ids`: Public subnet IDs
- `nat_gateway_ips`: NAT Gateway IPs

### aws-eks-cluster Module

Manages EKS cluster and add-ons:

**Variables:**
- `cluster_name`: Cluster name
- `cluster_version`: Kubernetes version
- `cluster_role_arn`: IAM role ARN
- `subnet_ids`: Subnet IDs for cluster
- `enable_oidc_provider`: Enable IRSA

**Outputs:**
- `cluster_id`: Cluster ID
- `cluster_endpoint`: API endpoint
- `oidc_provider_arn`: OIDC provider ARN
- `oidc_provider_url`: OIDC provider URL

### aws-iam-roles Module

Generic IAM role module:

**Variables:**
- `role_name`: Role name
- `assume_role_policy`: Assume role policy JSON
- `policy_arns`: List of policy ARNs to attach

**Outputs:**
- `role_arn`: Role ARN
- `role_name`: Role name
- `role_id`: Role ID

## Node Groups

### Default General Node Group

```hcl
node_groups = {
  general = {
    desired_size   = 2         # Ideal number of nodes
    min_size       = 1         # Minimum nodes during scale-down
    max_size       = 5         # Maximum nodes during scale-up
    instance_types = ["t3.medium"]
    disk_size      = 50        # GB
    capacity_type  = "ON_DEMAND"
    labels = {
      role = "general"
    }
  }
}
```

### Adding Spot Instances

```hcl
node_groups = {
  general = {
    # ... existing ...
  }
  
  spot_compute = {
    desired_size   = 1
    min_size       = 0
    max_size       = 3
    instance_types = ["t3.large", "t3a.large", "m5.large"]  # Multiple types for better Spot availability
    disk_size      = 50
    capacity_type  = "SPOT"
    labels = {
      role      = "compute"
      cost_type = "spot"
    }
  }
}
```

### GPU Node Group

```hcl
spot_gpu = {
  desired_size   = 0
  min_size       = 0
  max_size       = 2
  instance_types = ["g4dn.xlarge"]
  disk_size      = 100
  capacity_type  = "SPOT"
  labels = {
    role = "gpu"
  }
}
```

## Outputs and Usage

### Get Cluster Information

```bash
# Get all outputs
terraform output

# Get specific output
terraform output -raw cluster_id
terraform output -raw cluster_endpoint
terraform output -json | jq '.cluster_summary.value'
```

### Configure Applications

```bash
# Get cluster endpoint
CLUSTER_ENDPOINT=$(terraform output -raw cluster_endpoint)

# Use in Helm values
helm install my-app my-chart \
  --set kubeconfig.cluster=${CLUSTER_ENDPOINT}
```

## Post-Deployment Tasks

### 1. Verify Cluster Health

```bash
# Check nodes
kubectl get nodes
kubectl top nodes  # May take a minute to appear

# Check system pods
kubectl get pods -n kube-system
kubectl logs -n kube-system -l app=aws-node

# Check OIDC
kubectl get pods -n kube-system -l app.kubernetes.io/name=vpc-cni
```

### 2. Set Up IRSA (IAM Roles for Service Accounts)

```bash
# Get OIDC provider URL
OIDC_URL=$(terraform output -raw oidc_provider_url)
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)

# Create service account
kubectl create serviceaccount my-app -n default

# Create IAM role with IRSA
aws iam create-role \
  --role-name my-app-role \
  --assume-role-policy-document "{...}"  # See documentation

# Annotate service account
kubectl annotate serviceaccount my-app \
  -n default \
  eks.amazonaws.com/role-arn=arn:aws:iam::${AWS_ACCOUNT}:role/my-app-role
```

### 3. Deploy Applications

```bash
# Create deployment using service account
kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      serviceAccountName: my-app
      imagePullSecrets:
      - name: private-registry-credentials  # If using private registry
      containers:
      - name: app
        image: my-image:latest
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
EOF
```

## Updating Configuration

### Scale Node Groups

```hcl
# In terraform.tfvars
node_groups = {
  general = {
    desired_size = 5  # Changed from 2
    ...
  }
}
```

Then:
```bash
terraform plan -out=tfplan
terraform apply tfplan
```

### Add New Node Group

```hcl
# In terraform.tfvars
node_groups = {
  general = { ... }
  
  new_group = {
    desired_size   = 1
    min_size       = 0
    max_size       = 3
    instance_types = ["t3.large"]
    disk_size      = 50
    capacity_type  = "ON_DEMAND"
  }
}
```

### Upgrade Kubernetes

```hcl
# In terraform.tfvars
kubernetes_version = "1.30"  # Changed from 1.29
```

**Caution**: Review AWS documentation before upgrading.

## Cost Management

### Development

```hcl
single_nat_gateway = true              # Save on NAT costs
instance_types     = ["t3.small"]      # Smaller instances
capacity_type      = "SPOT"            # 70% cheaper
```

**Estimated monthly cost**: $50-100

### Production

```hcl
single_nat_gateway = false             # HA setup
instance_types     = ["t3.xlarge"]     # Larger instances
capacity_type      = "ON_DEMAND"       # Stable pricing
```

**Estimated monthly cost**: $500-1000

### Cost Monitoring

```bash
# List instances
aws ec2 describe-instances \
  --filters "Name=tag:ClusterName,Values=my-cluster" \
  --query 'Reservations[*].Instances[*].[InstanceType,State.Name]'

# Check NAT Gateway costs
terraform output nat_gateway_ips
```

## Troubleshooting

### Nodes Not Ready

```bash
# Check node logs
kubectl describe node <node-name>

# Via SSM
INSTANCE_ID=$(kubectl get nodes -o jsonpath='{.items[0].spec.providerID}' | cut -d'/' -f5)
aws ssm start-session --target ${INSTANCE_ID}
sudo tail -f /var/log/messages
```

### Pod Networking Issues

```bash
# Check VPC CNI
kubectl get daemonset -n kube-system aws-node
kubectl logs -n kube-system -l app=aws-node

# Check security groups
aws ec2 describe-security-groups --filters "Name=tag:Name,Values=*my-cluster*"
```

### Can't Access Cluster

```bash
# Update kubeconfig
eval "$(terraform output -raw configure_kubectl)"

# Verify endpoint is accessible
curl -k $(terraform output -raw cluster_endpoint)

# Check security group rules
aws ec2 describe-security-groups \
  --group-ids $(aws eks describe-cluster --name my-cluster --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text)
```

## Cleanup

### Destroy Cluster

```bash
# First, delete LoadBalancers and PVCs
kubectl delete svc --all --all-namespaces

# Destroy infrastructure
terraform destroy

# Confirm when prompted
```

**Note**: This will delete the cluster and all resources. Ensure data is backed up.

## References

- [Example Configurations](../example/)
- [Module Documentation](../../__modules/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)

---

**Version**: 1.0  
**Last Updated**: 2026-05-11
