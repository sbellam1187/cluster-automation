# Quick Start Guide

Get your EKS cluster up and running in 5 minutes!

## 1. Configure Your Cluster

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your settings
vim terraform.tfvars

# Key values to update:
# - cluster_name = "my-cluster"
# - environment = "dev" or "prod"
# - project_name = "my-project"
# - aws_region = "us-east-1"
```

## 2. Update Backend Configuration

Edit `backend.tf` and set your S3 bucket:

```hcl
backend "s3" {
  bucket         = "my-terraform-state-bucket"  # Change this
  key            = "eks/terraform.tfstate"
  region         = "us-east-1"
  encrypt        = true
  dynamodb_table = "terraform-locks"
}
```

## 3. Deploy Cluster

```bash
# Initialize Terraform
make init

# Validate configuration
make validate

# Create plan
make plan

# Apply (takes 15-20 minutes)
make apply
```

## 4. Access Your Cluster

```bash
# Configure kubectl
make kubeconfig

# Verify access
make test-cluster
```

## Common Operations

### View Outputs
```bash
make output
```

### View Logs
```bash
make logs
```

### Scale Node Groups
Edit `terraform.tfvars`, update `node_groups.desired_size`, then:
```bash
make plan && make apply
```

### Destroy Everything
```bash
make destroy
```

## Troubleshooting

### Nodes not ready?
```bash
kubectl describe node <node-name>
kubectl get pods -n kube-system
```

### Can't access cluster?
```bash
make kubeconfig
```

### Still stuck?
See full documentation in [README.md](README.md) and [DEPLOYMENT.md](DEPLOYMENT.md)

## Cost Tips

- Use `t3.medium` for dev/test
- Set `single_nat_gateway = true` for dev
- Use spot instances for non-critical workloads
- Remove cluster when not in use: `make destroy`

---

More help: `make help`
