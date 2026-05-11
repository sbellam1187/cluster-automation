# GKE Cluster Terraform - Implementation Guide

This guide explains the modular Terraform structure for deploying Google Kubernetes Engine (GKE) clusters on Google Cloud Platform (GCP).

## Overview

The GKE configuration follows the same modular pattern as the EKS implementation, providing reusable components for building cloud-native infrastructure.

## Directory Structure

```
terraform/
├── __modules/
│   ├── google-gke-cluster/    # GKE cluster module
│   ├── google-vpc/            # VPC networking module
│   ├── google-iam-roles/      # IAM service accounts
│   └── ... (other modules)
│
└── gke-cluster/
    ├── example/               # Complete working example
    │   ├── main.tf           # Module composition
    │   ├── variables.tf      # 40+ input variables
    │   ├── outputs.tf        # Output values
    │   ├── providers.tf      # GCP provider config
    │   ├── terraform.tfvars.example
    │   └── README.md         # Deployment guide
    └── lab/                  # Additional environments
```

## Modules Overview

### 1. google-vpc Module
**Purpose**: Create VPC network and configure networking

**Key Resources**:
- VPC network
- Subnets with secondary IP ranges (pods, services)
- Cloud Router
- Cloud NAT

**Usage**:
```hcl
module "vpc" {
  source = "../../__modules/google-vpc"
  
  project_id      = var.project_id
  region          = var.region
  network_name    = "gke-network"
  subnet_cidr     = "10.0.0.0/24"
  
  secondary_ranges = {
    pods     = "10.4.0.0/14"
    services = "10.0.0.0/20"
  }
}
```

### 2. google-iam-roles Module
**Purpose**: Create service accounts and manage IAM bindings

**Key Resources**:
- Google Service Account
- IAM role bindings
- Service account key management

**Usage**:
```hcl
module "gke_service_account" {
  source = "../../__modules/google-iam-roles"
  
  project_id           = var.project_id
  service_account_name = "gke-nodes"
  roles = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter"
  ]
}
```

### 3. google-gke-cluster Module
**Purpose**: Create and configure GKE cluster

**Key Resources**:
- GKE cluster
- Node pools with auto-scaling
- RBAC configuration
- Security features
- Monitoring and logging

**Usage**:
```hcl
module "gke_cluster" {
  source = "../../__modules/google-gke-cluster"
  
  project_id        = var.project_id
  cluster_name      = "my-cluster"
  region            = "us-central1"
  kubernetes_version = "1.29"
  
  machine_type      = "e2-standard-2"
  initial_node_count = 1
  max_node_count    = 10
}
```

## Quick Start

### 1. Navigate to Example

```bash
cd terraform/gke-cluster/example
```

### 2. Configure

```bash
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars

# Update these required values:
# - project_id: Your GCP project ID
# - cluster_name: Desired cluster name
# - region: GCP region
```

### 3. Initialize

```bash
terraform init
```

### 4. Review

```bash
terraform plan -out=tfplan
terraform show tfplan
```

### 5. Deploy

```bash
terraform apply tfplan
```

### 6. Access

```bash
eval "$(terraform output -raw configure_kubectl)"
kubectl get nodes
```

## Module Composition (main.tf)

The example `main.tf` demonstrates how modules are composed:

```hcl
# 1. Create VPC and networking
module "vpc" {
  source = "../../__modules/google-vpc"
  project_id = var.project_id
  # ... configuration
}

# 2. Create service account for nodes
module "gke_service_account" {
  source = "../../__modules/google-iam-roles"
  project_id = var.project_id
  # ... configuration
}

# 3. Create GKE cluster using VPC and service account
module "gke_cluster" {
  source = "../../__modules/google-gke-cluster"
  project_id = var.project_id
  network_name = module.vpc.network_name
  subnet_name = module.vpc.subnet_name
  node_service_account_email = module.gke_service_account.email
  # ... configuration
}
```

## Configuration Variables

### Required
- `project_id` - GCP Project ID
- `cluster_name` - Cluster name
- `region` - GCP region (e.g., us-central1)

### Cluster Configuration
- `environment` - dev/staging/prod
- `kubernetes_version` - Kubernetes version (default: 1.29)
- `enable_private_cluster` - Private GKE nodes (default: true)

### Node Configuration
- `machine_type` - VM type (default: e2-standard-2)
- `initial_node_count` - Initial nodes (default: 1)
- `max_node_count` - Max nodes for auto-scaling (default: 10)
- `enable_preemptible_nodes` - Use spot VMs (default: false)

### Network Configuration
- `subnet_cidr` - Primary subnet range
- `secondary_ip_range_pods` - Pod IP range
- `secondary_ip_range_services` - Service IP range

### Security Features
- `enable_workload_identity` - Pod IAM (default: true)
- `enable_shielded_nodes` - Security hardening (default: true)
- `enable_network_policy` - Calico policies (default: true)
- `enable_pod_security_policy` - Pod security (default: true)

### Monitoring
- `enable_logging` - Cloud Logging (default: true)
- `enable_monitoring` - Cloud Monitoring (default: true)

## Environment-Specific Examples

### Development Environment

```bash
mkdir -p terraform/gke-cluster/dev
cp -r terraform/gke-cluster/example/* terraform/gke-cluster/dev/
cd terraform/gke-cluster/dev
```

**terraform.tfvars**:
```hcl
project_id       = "my-project-dev"
cluster_name     = "dev-cluster"
region           = "us-central1"
environment      = "dev"
machine_type     = "e2-standard-2"
max_node_count   = 3
enable_preemptible_nodes = true
```

### Production Environment

```bash
mkdir -p terraform/gke-cluster/prod
cp -r terraform/gke-cluster/example/* terraform/gke-cluster/prod/
cd terraform/gke-cluster/prod
```

**terraform.tfvars**:
```hcl
project_id       = "my-project-prod"
cluster_name     = "prod-cluster"
region           = "us-central1"
environment      = "prod"
machine_type     = "n1-standard-4"
max_node_count   = 20
enable_preemptible_nodes = false
enable_private_cluster = true
enable_shielded_nodes = true
enable_network_policy = true
```

## Deployment Flow

```
1. Authenticate to GCP
   └─ gcloud auth application-default login

2. Configure
   └─ cp terraform.tfvars.example terraform.tfvars
   └─ Update project_id, cluster_name, region

3. Initialize
   └─ terraform init

4. Plan
   └─ terraform plan -out=tfplan

5. Review
   └─ terraform show tfplan

6. Deploy
   └─ terraform apply tfplan

7. Configure kubectl
   └─ eval "$(terraform output -raw configure_kubectl)"

8. Verify
   └─ kubectl get nodes
   └─ kubectl get pods -A

9. Deploy Application
   └─ kubectl apply -f app.yaml
```

## Output Values

The example provides outputs for cluster access:

```hcl
terraform output cluster_name      # Cluster name
terraform output cluster_endpoint  # API endpoint
terraform output region           # GCP region
terraform output zones            # Availability zones
terraform output configure_kubectl # kubectl config command
```

## Key Features

### ✅ Networking
- VPC with configurable CIDR ranges
- Secondary IP ranges for pods and services
- Cloud NAT for private clusters
- Cloud Router for dynamic routing

### ✅ GKE Cluster
- Configurable Kubernetes version
- Private or public clusters
- Auto-scaling node pools
- Release channel management

### ✅ Security
- Workload Identity (pod IAM)
- Shielded nodes
- Network policies (Calico)
- Pod security policies
- Binary authorization support
- Private Google Access

### ✅ Monitoring
- Cloud Logging integration
- Cloud Monitoring metrics
- Control plane audit logs
- Node and pod monitoring

### ✅ Service Accounts
- GKE node service account
- IAM role bindings
- Workload Identity support

## Module Communication

Modules interact through:

1. **Outputs**: VPC outputs used by cluster module
   ```hcl
   network_name = module.vpc.network_name
   subnet_name  = module.vpc.subnet_name
   ```

2. **Dependencies**: `depends_on` ensures correct ordering
   ```hcl
   depends_on = [module.vpc, module.gke_service_account]
   ```

3. **Data Sources**: Kubernetes provider auto-discovers cluster
   ```hcl
   data "google_client_config" "default" {}
   ```

## Benefits of Modular Structure

### Reusability
- Create multiple clusters with one configuration
- Share modules across projects
- Easy to customize per environment

### Maintainability
- Bug fixes apply everywhere
- Clear separation of concerns
- Easy to test and validate

### Scalability
- Add new modules easily
- Support multiple teams
- Grow infrastructure consistently

### Flexibility
- Override any variable
- Mix and match modules
- Conditional resource creation

## Comparison: GKE vs EKS

| Feature | GKE | EKS |
|---------|-----|-----|
| Provider | Google Cloud | AWS |
| Networking | VPC + Cloud NAT | VPC + NAT Gateway |
| Node Management | Managed | Managed |
| Service Accounts | GCP Service Accounts | IAM Roles |
| Pod IAM | Workload Identity | IRSA |
| Monitoring | Cloud Logging | CloudWatch |
| Cost Model | Per-hour + compute | Hourly + compute |

## Common Tasks

### Scale Cluster

```hcl
# In terraform.tfvars
max_node_count = 20
```

Then:
```bash
terraform plan
terraform apply
```

### Update Kubernetes

```hcl
# In terraform.tfvars
kubernetes_version = "1.30"
```

### Add Authorized Network

```hcl
authorized_networks = [
  {
    name = "office"
    cidr = "203.0.113.0/24"
  }
]
```

## Cost Optimization

### Development
- Preemptible nodes: 70% cost reduction
- Smaller machines: e2-standard-2
- Single node: Cost $40-50/month

### Production
- Standard nodes for reliability
- Larger machines for workloads
- Multiple zones for HA: Cost $500-1000/month

## Documentation Structure

### For Operators
1. Read [gke-cluster/example/README.md](gke-cluster/example/README.md)
2. Customize terraform.tfvars
3. Deploy and manage

### For Developers
1. Review module files in `__modules/`
2. Understand composition in `main.tf`
3. Customize variables

### For Architects
1. Study module interactions
2. Plan multi-environment strategy
3. Design governance

## Next Steps

1. **Get Started**:
   ```bash
   cd terraform/gke-cluster/example
   cp terraform.tfvars.example terraform.tfvars
   vim terraform.tfvars
   ```

2. **Deploy**:
   ```bash
   terraform init
   terraform apply
   ```

3. **Verify**:
   ```bash
   kubectl get nodes
   kubectl get pods -A
   ```

4. **Extend**:
   - Add monitoring (Prometheus, Grafana)
   - Deploy sample application
   - Configure security policies

## Support Resources

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google)
- [GCP IAM Documentation](https://cloud.google.com/iam/docs)
- [GKE Security Best Practices](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster)

## Summary

The GKE modular configuration provides:

✅ **Reusable modules** for VPC, IAM, and clusters  
✅ **Working example** in `gke-cluster/example/`  
✅ **Complete documentation** for deployment  
✅ **Multiple environment** support (dev/staging/prod)  
✅ **Production-ready** configuration  
✅ **Security best practices** enabled by default  

Start with the example, customize for your needs, and deploy!

---

**Version**: 1.0  
**Last Updated**: 2026-05-11  
**Terraform Version**: >= 1.0  
**Google Provider Version**: ~> 5.0
