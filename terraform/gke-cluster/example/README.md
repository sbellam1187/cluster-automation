# GKE Cluster Example

Production-ready GKE cluster example configuration using the `google-gke-infrastructure` module.

## Overview

This example demonstrates how to deploy a complete Google Kubernetes Engine infrastructure using Terraform. It includes:

- **VPC Network** - Private VPC with secondary IP ranges
- **GKE Cluster** - Regional multi-zone cluster with private nodes
- **Multiple Node Pools** - Different machine types for various workloads
- **Workload Identity** - Pod-to-GCP service account mapping
- **Security** - Network policies, shielded nodes, RBAC
- **Monitoring** - Cloud Logging and Cloud Monitoring integration

## Quick Start

### 1. Set Up GCP Project

```bash
# Set your project ID
export PROJECT_ID="your-project-id"

# Create project (if new)
gcloud projects create $PROJECT_ID

# Set as default
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable logging.googleapis.com
gcloud services enable monitoring.googleapis.com
```

### 2. Authenticate with Google Cloud

```bash
gcloud auth login
gcloud auth application-default login
```

### 3. Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
cat > terraform.tfvars <<EOF
project_id   = "$PROJECT_ID"
region       = "us-central1"
cluster_name = "my-gke-cluster"

node_pools = {
  general = {
    min_node_count = 1
    max_node_count = 5
    machine_type   = "n2-standard-2"
    disk_size_gb   = 50
    labels = {
      workload = "general"
    }
  }
}

resource_labels = {
  environment = "dev"
  team        = "platform"
}
EOF
```

### 4. Deploy Cluster

```bash
terraform init
terraform plan
terraform apply
```

### 5. Configure kubectl

```bash
# Use the output command
gcloud container clusters get-credentials my-gke-cluster \
  --region us-central1 \
  --project $PROJECT_ID

# Verify connection
kubectl cluster-info
kubectl get nodes
```

## Enterprise Features

### Production Security

✅ **Private Cluster** - Nodes have only private IPs  
✅ **Workload Identity** - Pod-to-GCP authentication  
✅ **Network Policies** - Pod communication control  
✅ **Shielded Nodes** - Secure Boot + Integrity Monitoring  
✅ **Binary Authorization** - Container image verification  
✅ **RBAC** - Role-based access control  

### High Availability

✅ **Regional Cluster** - Multi-zone automatic failover  
✅ **Auto-scaling** - Dynamic node provisioning  
✅ **Auto-repair** - Automatic node recovery  
✅ **Auto-upgrade** - Scheduled Kubernetes updates  

### Operations

✅ **Cloud Logging** - Container and system logs  
✅ **Cloud Monitoring** - Metrics and dashboards  
✅ **Maintenance Windows** - Scheduled updates  
✅ **Multiple Node Pools** - Workload isolation  

## Module Usage

```hcl
module "gke" {
  source = "../../__modules/google-gke-infrastructure"

  project_id   = var.project_id
  region       = var.region
  cluster_name = var.cluster_name

  # Network
  network_name       = "my-network"
  enable_private_cluster = true

  # Features
  enable_workload_identity = true
  enable_network_policy    = true
  enable_shielded_nodes    = true

  # Node pools
  node_pools = var.node_pools

  # Labels
  resource_labels = {
    environment = "prod"
  }
}
```

## Configuration Examples

See [../../__modules/google-gke-infrastructure/README.md](../../__modules/google-gke-infrastructure/README.md) for detailed configuration options and best practices.

This directory contains a complete, production-ready Terraform configuration for deploying Google Kubernetes Engine (GKE) clusters on Google Cloud Platform (GCP).

## Quick Start

### 1. Prerequisites

```bash
# Install required tools
gcloud --version        # >= 420.0
terraform --version    # >= 1.0
kubectl --version      # >= 1.24
```

### 2. Authenticate to GCP

```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 3. Configure

```bash
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
# Update: project_id, region, cluster_name
```

### 4. Deploy

```bash
terraform init
terraform plan -out=tfplan
terraform apply tfplan
```

### 5. Access Cluster

```bash
eval "$(terraform output -raw configure_kubectl)"
kubectl get nodes
```

## Configuration

### Required Variables

```hcl
project_id      = "your-gcp-project"
cluster_name    = "my-cluster"
region          = "us-central1"
environment     = "dev"
```

### Common Scenarios

#### Development Cluster (Minimal Cost)
```hcl
machine_type           = "e2-standard-2"
initial_node_count     = 1
max_node_count         = 3
enable_preemptible_nodes = true
```

#### Production Cluster (HA)
```hcl
machine_type           = "n1-standard-4"
initial_node_count     = 3
max_node_count         = 10
enable_preemptible_nodes = false
enable_private_cluster = true
enable_shielded_nodes  = true
enable_network_policy  = true
```

#### With Custom Network
```hcl
network_name             = "prod-network"
subnet_name              = "prod-subnet"
subnet_cidr              = "10.0.0.0/24"
secondary_ip_range_pods  = "10.4.0.0/14"
secondary_ip_range_services = "10.0.0.0/20"
```

## Architecture

### Module Composition

```
├── google-vpc/              # VPC network, subnets, Cloud NAT
├── google-iam-roles/        # Service accounts and IAM bindings
└── google-gke-cluster/      # GKE cluster and node pools
```

### Network Architecture

```
┌─────────────────────────────────────┐
│     GCP Project (project_id)        │
├─────────────────────────────────────┤
│  VPC Network                        │
│  ├─ Subnet (10.0.0.0/24)           │
│  │  ├─ Pods (10.4.0.0/14)          │
│  │  └─ Services (10.0.0.0/20)      │
│  ├─ Cloud Router                   │
│  └─ Cloud NAT                      │
│                                     │
│  GKE Cluster                       │
│  ├─ Control Plane (managed)        │
│  └─ Node Pool (Compute Engine)     │
│                                     │
│  Service Accounts                  │
│  └─ GKE Node Service Account       │
└─────────────────────────────────────┘
```

## Input Variables

### GCP Configuration
- `project_id` - GCP Project ID (required)
- `region` - GCP region (default: us-central1)

### Cluster Configuration
- `cluster_name` - Cluster name
- `environment` - Environment name (dev/staging/prod)
- `kubernetes_version` - Kubernetes version (default: 1.29)

### Network Configuration
- `network_name` - VPC network name
- `subnet_name` - Subnet name
- `subnet_cidr` - Primary subnet CIDR
- `secondary_ip_range_pods` - Pod IP range
- `secondary_ip_range_services` - Service IP range

### Node Configuration
- `machine_type` - Machine type for nodes (default: e2-standard-2)
- `initial_node_count` - Initial nodes per zone (default: 1)
- `min_node_count` - Minimum nodes per zone (default: 1)
- `max_node_count` - Maximum nodes per zone (default: 10)
- `disk_size_gb` - Node disk size (default: 100)
- `disk_type` - Disk type: pd-standard or pd-ssd (default: pd-standard)
- `enable_preemptible_nodes` - Use spot VMs (default: false)

### Security Features
- `enable_private_cluster` - Private GKE nodes (default: true)
- `authorized_networks` - Networks allowed to access control plane
- `enable_workload_identity` - Workload Identity (default: true)
- `enable_shielded_nodes` - Security hardening (default: true)
- `enable_network_policy` - Calico policies (default: true)
- `enable_pod_security_policy` - Pod security (default: true)
- `enable_binary_authorization` - Image verification (default: false)

### Monitoring & Logging
- `enable_logging` - Cloud Logging (default: true)
- `enable_monitoring` - Cloud Monitoring (default: true)

### Maintenance & Backup
- `maintenance_window_start_time` - Maintenance start (RFC 3339)
- `maintenance_window_duration` - Window duration in hours (default: 4)
- `enable_gke_backup` - GKE Backup (default: true)

## Output Values

```bash
terraform output cluster_name      # Cluster name
terraform output cluster_endpoint  # Cluster endpoint
terraform output region           # GCP region
terraform output zones            # Zones used
terraform output node_pool_id     # Node pool ID
terraform output configure_kubectl # kubectl config command
```

## Deployment Workflow

### 1. Initialize
```bash
terraform init
```

### 2. Plan
```bash
terraform plan -out=tfplan
terraform show tfplan
```

### 3. Apply
```bash
terraform apply tfplan
```

### 4. Verify
```bash
eval "$(terraform output -raw configure_kubectl)"
kubectl cluster-info
kubectl get nodes
kubectl get pods -A
```

### 5. Deploy Application
```bash
kubectl apply -f app.yaml
kubectl port-forward svc/my-app 8080:80
```

## Common Tasks

### Access Cluster

```bash
gcloud container clusters get-credentials CLUSTER_NAME --region REGION
kubectl get nodes
```

### Update Node Count

```hcl
# In terraform.tfvars
initial_node_count = 3
```

Then:
```bash
terraform plan
terraform apply
```

### Update Kubernetes Version

```hcl
# In terraform.tfvars
kubernetes_version = "1.30"
```

Then:
```bash
terraform plan
terraform apply
```

### Scale Machine Type

```hcl
# In terraform.tfvars
machine_type = "n1-standard-4"
```

Then recreate node pool:
```bash
terraform plan
terraform apply
```

### Enable Private Registry Access

Create a Kubernetes secret for authentication:

```bash
kubectl create secret docker-registry image-pull-secret \
  --docker-server=gcr.io \
  --docker-username=oauth2accesstoken \
  --docker-password="$(gcloud auth application-default print-access-token)" \
  --docker-email=serviceaccount@example.com
```

### Configure Workload Identity

Bind Kubernetes service account to GCP service account:

```bash
kubectl create serviceaccount my-app

gcloud iam service-accounts create my-app

gcloud iam service-accounts add-iam-policy-binding my-app@PROJECT_ID.iam.gserviceaccount.com \
  --role roles/iam.workloadIdentityUser \
  --member serviceAccount:PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]
```

## Troubleshooting

### Cannot access cluster
```bash
# Verify credentials
gcloud auth application-default login

# Check cluster connectivity
terraform output cluster_endpoint

# Get credentials
gcloud container clusters get-credentials CLUSTER_NAME --region REGION
```

### Nodes not ready
```bash
# Check node status
kubectl get nodes
kubectl describe node NODE_NAME

# Check logs
kubectl logs -n kube-system -l component=kubelet
```

### Pod network issues
```bash
# Verify network policy
kubectl get networkpolicies

# Check service connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
nslookup kubernetes.default
```

### Quota exceeded
```bash
# Check quotas
gcloud compute project-info describe --project=PROJECT_ID

# Reduce cluster size or request quota increase
```

## Cost Optimization

### Development
- Use preemptible nodes: `enable_preemptible_nodes = true`
- Use smaller machines: `machine_type = "e2-standard-2"`
- Reduce node count: `initial_node_count = 1`
- **Estimated Cost**: $50-100/month

### Production
- Use on-demand nodes: `enable_preemptible_nodes = false`
- Use standard machines: `machine_type = "n1-standard-4"`
- Maintain multiple nodes: `initial_node_count = 3`
- **Estimated Cost**: $500-1000/month

### Cost Monitoring
```bash
# View cluster costs
gcloud compute instances list
gcloud compute disks list

# Set budget alerts
gcloud billing budgets create --billing-account ACCOUNT_ID
```

## Security Best Practices

✅ **Enabled by default:**
- Private cluster (private nodes)
- Workload Identity
- Shielded nodes
- Network policies
- Pod security policies

### Additional hardening:
```hcl
enable_private_cluster          = true
enable_workload_identity        = true
enable_shielded_nodes           = true
enable_network_policy           = true
enable_pod_security_policy      = true
enable_binary_authorization     = true
```

### Network security:
```hcl
authorized_networks = [
  {
    name = "office"
    cidr = "203.0.113.0/24"
  }
]
```

## Monitoring & Logging

### Cloud Logging
- Automatically enabled with `enable_logging = true`
- Access via Cloud Console: Logs > Cloud Logging

### Cloud Monitoring
- Automatically enabled with `enable_monitoring = true`
- Access via Cloud Console: Monitoring > Metrics

### Application Monitoring
```bash
# Deploy Prometheus
kubectl apply -f https://github.com/prometheus-operator/kube-prometheus-stack/releases/latest

# Deploy Grafana
helm install grafana grafana/grafana -n monitoring
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

To destroy specific resource:
```bash
terraform destroy -target 'google_container_cluster.primary'
```

## File Structure

```
├── providers.tf              # GCP provider config
├── variables.tf             # Input variables
├── main.tf                  # Module composition
├── outputs.tf               # Output values
├── terraform.tfvars.example # Example config
└── README.md               # This file
```

## Related Documentation

- [Google GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest)
- [GCP IAM Roles Reference](https://cloud.google.com/iam/docs/understanding-roles)
- [GKE Security Best Practices](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster)

## Support

For issues or questions:
1. Check [GKE Troubleshooting Guide](https://cloud.google.com/kubernetes-engine/docs/troubleshooting)
2. Review module README files
3. Check Terraform state: `terraform state list`

---

**Version**: 1.0  
**Last Updated**: 2026-05-11  
**Terraform Version**: >= 1.0  
**Google Provider Version**: ~> 5.0
