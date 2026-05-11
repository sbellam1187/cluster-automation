# EKS Cluster Deployment Guide

This guide provides detailed step-by-step instructions for deploying the EKS cluster using this Terraform configuration.

## Prerequisites Checklist

- [ ] AWS account with appropriate IAM permissions
- [ ] Terraform 1.0+ installed (`terraform version`)
- [ ] AWS CLI v2 installed and configured (`aws --version`)
- [ ] kubectl installed (`kubectl version`)
- [ ] jq installed for JSON parsing (optional but recommended)
- [ ] S3 bucket for Terraform state
- [ ] DynamoDB table for state locking (optional)

## Pre-Deployment Setup

### 1. Prepare AWS Account

```bash
# Set your AWS profile
export AWS_PROFILE=your-profile

# Verify AWS credentials
aws sts get-caller-identity

# Create S3 bucket for Terraform state (if not exists)
aws s3api create-bucket \
  --bucket terraform-state-eks-cluster \
  --region us-east-1

# Enable versioning on bucket
aws s3api put-bucket-versioning \
  --bucket terraform-state-eks-cluster \
  --versioning-configuration Status=Enabled

# Enable encryption on bucket
aws s3api put-bucket-encryption \
  --bucket terraform-state-eks-cluster \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# Create DynamoDB table for state locking (optional but recommended)
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-east-1
```

### 2. Clone Repository

```bash
cd /Users/134951/development/cluster-automation
ls -la
```

### 3. Configure Backend

Edit `backend.tf` with your actual bucket details:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-eks-cluster"  # Update this
    key            = "eks/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

### 4. Create terraform.tfvars

```bash
# Copy the example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
# IMPORTANT: Update these critical values:
# - cluster_name
# - environment
# - project_name
# - aws_region
# - private_registry_* (if using private registry)

# For private registries:
# - Set enable_ecr_access = false
# - Fill in private_registry_url, username, password

# For security:
# - Restrict cluster_endpoint_public_access_cidrs
# - Review enable_imds_v2, enable_ssm_access, enable_monitoring
```

## Deployment Steps

### Step 1: Terraform Initialization

```bash
# Initialize Terraform
terraform init

# Confirm backend configuration
# You should see: "Successfully configured the backend" message
```

### Step 2: Validate Configuration

```bash
# Validate Terraform syntax
terraform validate

# Format code for consistency
terraform fmt -recursive

# Check for any issues
terraform validate
```

### Step 3: Create Terraform Plan

```bash
# Generate execution plan
terraform plan -out=tfplan

# This will output:
# - Resources to be created (200+)
# - Estimated cost changes
# - Any warnings or errors

# Save the output for review
terraform plan -out=tfplan > plan.log 2>&1
```

### Step 4: Review the Plan

```bash
# Show the plan summary
terraform show tfplan | head -100

# Count resources to be created
terraform show -json tfplan | jq '.resource_changes | length'

# Review specific resource types
terraform show tfplan | grep "aws_eks_cluster"
terraform show tfplan | grep "aws_subnet"
```

### Step 5: Apply Configuration

```bash
# Apply the configuration
# This will take 15-20 minutes
terraform apply tfplan

# You should see:
# Apply complete! Resources: X added, 0 changed, 0 destroyed.

# If you get errors, review them and fix your configuration
```

### Step 6: Verify Cluster Creation

```bash
# Get cluster outputs
terraform output cluster_id
terraform output cluster_endpoint
terraform output vpc_id

# Check cluster in AWS
aws eks describe-cluster --name $(terraform output -raw cluster_id) --region $(terraform output -raw aws_region)

# Verify node groups
aws eks list-nodegroups --cluster-name $(terraform output -raw cluster_id)
```

### Step 7: Configure kubectl

```bash
# Get the kubeconfig update command
KUBECONFIG_CMD=$(terraform output -raw configure_kubectl)
echo $KUBECONFIG_CMD

# Execute it
eval $KUBECONFIG_CMD

# Verify kubeconfig
kubectl config current-context
kubectl cluster-info
```

### Step 8: Verify Cluster Access

```bash
# List nodes
kubectl get nodes
# Expected: Worker nodes in Ready state

# List system namespaces
kubectl get namespaces

# Check kube-system pods
kubectl get pods -n kube-system
# Expected: CoreDNS, kube-proxy, aws-node pods running

# Check cluster information
kubectl cluster-info

# Verify OIDC provider
kubectl get serviceaccount -A -o jsonpath='{.items[*].metadata.annotations.eks\.amazonaws\.com/role-arn}' | grep arn || echo "No IRSA yet (expected)"
```

## Post-Deployment Tasks

### 1. Verify Add-ons

```bash
# Check installed add-ons
aws eks list-addons --cluster-name $(terraform output -raw cluster_id)

# Get add-on details
aws eks describe-addon --cluster-name $(terraform output -raw cluster_id) --addon-name vpc-cni
```

### 2. Test Private Registry (if configured)

```bash
# Check if secrets were created
kubectl get secrets
# Should see: private-registry-credentials, private-registry-secret

# Test with a pod
kubectl run test-pod --image=<your-private-registry>/test-image --image-pull-policy=Always --restart=Never
kubectl describe pod test-pod
kubectl logs test-pod
```

### 3. Set Up IRSA (if enabled)

```bash
# Verify OIDC provider
OIDC_URL=$(terraform output -raw oidc_provider_url)
echo "OIDC Provider URL: $OIDC_URL"

# Get the identity certificate
aws iam list-open-id-connect-providers | grep $OIDC_URL

# You can now create service accounts with IAM roles
```

### 4. Enable CloudWatch Logging

```bash
# View logs
CLUSTER_NAME=$(terraform output -raw cluster_id)
aws logs describe-log-groups --log-group-name-prefix /aws/eks/$CLUSTER_NAME

# Tail logs
aws logs tail /aws/eks/$CLUSTER_NAME/cluster --follow

# View specific log type (e.g., audit logs)
aws logs tail /aws/eks/$CLUSTER_NAME/cluster --log-stream-name-prefix audit --follow
```

### 5. Configure Auto-Scaling (Optional)

```bash
# Install Cluster Autoscaler using Helm
# Or use Karpenter for more advanced scaling

helm repo add autoscaling https://kubernetes.github.io/autoscaler
helm install cluster-autoscaler autoscaling/cluster-autoscaler \
  --namespace kube-system \
  --set autoDiscovery.clusterName=$(terraform output -raw cluster_id) \
  --set awsRegion=$(terraform output -raw aws_region)
```

## Updating Configuration

### Scaling Node Groups

```hcl
# In terraform.tfvars, update node groups:
node_groups = {
  general = {
    desired_size   = 3  # Increased from 2
    min_size       = 1
    max_size       = 10 # Increased from 5
    instance_types = ["t3.large"] # Changed from t3.medium
    disk_size      = 100 # Increased from 50
    ...
  }
}
```

Then:

```bash
terraform plan -out=tfplan
terraform apply tfplan
```

### Upgrading Kubernetes Version

```hcl
# In terraform.tfvars:
cluster_version = "1.30"  # Update from 1.29
```

Then:

```bash
terraform plan -out=tfplan
# Review carefully - upgrades are destructive
terraform apply tfplan
```

### Adding Node Groups

```hcl
# In terraform.tfvars:
node_groups = {
  general = {
    # ... existing configuration
  }
  gpu = {  # New node group
    desired_size   = 1
    min_size       = 0
    max_size       = 3
    instance_types = ["g4dn.xlarge"]
    disk_size      = 100
    capacity_type  = "ON_DEMAND"
    labels = {
      role = "gpu"
    }
    taints = [{
      key    = "nvidia.com/gpu"
      value  = "true"
      effect = "NoSchedule"
    }]
  }
}
```

## Troubleshooting Deployment

### Terraform Init Fails

```bash
# Check AWS credentials
aws sts get-caller-identity

# Check S3 bucket exists
aws s3 ls terraform-state-eks-cluster

# Check DynamoDB table exists
aws dynamodb list-tables | grep terraform-locks

# Try initialization with verbose output
TF_LOG=DEBUG terraform init
```

### Terraform Plan Fails

```bash
# Check AWS permissions
aws ec2 describe-vpcs
aws eks describe-clusters

# Check variable validation
terraform validate

# Check for syntax errors
terraform fmt -check

# Try with more verbose logging
TF_LOG=DEBUG terraform plan -out=tfplan
```

### Terraform Apply Fails

```bash
# Common issues:
# 1. Insufficient permissions - verify IAM role
# 2. Resource quotas exceeded - check service quotas
# 3. Invalid CIDR blocks - verify vpc_cidr and subnet_cidrs

# Check CloudFormation events for EKS creation
aws cloudformation describe-stack-events --stack-name eksctl-<cluster-name>-cluster

# Check EKS cluster status
aws eks describe-cluster --name <cluster-name>

# Check node group status
aws eks describe-nodegroup --cluster-name <cluster-name> --nodegroup-name <nodegroup-name>
```

### Cluster Not Accessible

```bash
# Update kubeconfig
aws eks update-kubeconfig --region $(terraform output -raw aws_region) --name $(terraform output -raw cluster_id)

# Check kubeconfig context
kubectl config get-contexts

# Verify API endpoint is accessible
curl -k $(terraform output -raw cluster_endpoint)

# Check security group rules
aws ec2 describe-security-groups --group-ids $(terraform output cluster_security_group_id | grep -o 'sg-[^"]*')

# Check node security groups
aws ec2 describe-security-groups --filters Name=tag:Name,Values=$(terraform output -raw cluster_id)-node-sg
```

### Nodes Not Ready

```bash
# Check node status
kubectl get nodes -o wide

# Describe node issues
kubectl describe node <node-name>

# Check node logs via SSM
INSTANCE_ID=$(kubectl get nodes -o jsonpath='{.items[0].spec.providerID}' | cut -d'/' -f5)
aws ssm start-session --target $INSTANCE_ID

# Inside the session:
tail -f /var/log/messages
systemctl status kubelet
journalctl -u kubelet -n 50
```

## Destroying the Cluster

⚠️ **WARNING**: This action cannot be undone!

```bash
# First, delete any resources created by your applications
kubectl delete all --all --all-namespaces

# Delete any load balancers
kubectl delete svc --all --all-namespaces

# Destroy all infrastructure
terraform destroy

# Confirm the destruction when prompted

# Verify resources are destroyed
aws eks list-clusters
aws ec2 describe-vpcs --filters Name=tag:Name,Values=<cluster-name>-vpc
```

## Cost Monitoring

```bash
# Get NAT Gateway costs (usually largest cost)
terraform output nat_gateway_ips

# List all instances
aws ec2 describe-instances --filters Name=tag:Name,Values=<cluster-name>* --query 'Reservations[*].Instances[*].[InstanceId,InstanceType,State.Name]'

# Check Elastic IPs cost
aws ec2 describe-addresses | grep PublicIp

# Use AWS Cost Explorer for detailed analysis
# Visit: https://console.aws.amazon.com/cost-management/home
```

## Maintenance

### Regular Tasks

- Monitor cluster logs daily
- Review and update node group versions monthly
- Audit security groups quarterly
- Review IAM policies and OIDC usage

### Backup Recommendations

```bash
# Backup kubeconfig
cp ~/.kube/config backup-kubeconfig-$(date +%Y%m%d).yaml

# Export cluster configuration
terraform state pull > backup-terraform-state-$(date +%Y%m%d).json

# Document cluster setup
terraform output > cluster-outputs-$(date +%Y%m%d).txt
```

## Getting Help

- **Terraform Issues**: `terraform state list`, `terraform state show <resource>`
- **AWS Issues**: Check CloudFormation events, VPC Flow Logs
- **Kubernetes Issues**: `kubectl describe`, `kubectl logs`, `kubectl events`
- **Documentation**: See README.md and comments in each .tf file

---

**Last Updated**: 2026-05-11
**Estimated Deploy Time**: 15-20 minutes
