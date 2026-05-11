# Google Kubernetes Engine (GKE) Infrastructure Module

Enterprise-ready GKE infrastructure module - Complete stack with VPC, security, monitoring, and workload identity in one place.

## Features

✅ **VPC Network** - Configurable network with secondary IP ranges  
✅ **Private Cluster** - Private nodes with Cloud NAT for egress  
✅ **Workload Identity** - Pod-to-GCP service account mapping (modern workload IAM)  
✅ **Network Security** - Kubernetes network policy support  
✅ **RBAC & IAM** - Full role-based access control setup  
✅ **Multiple Node Pools** - Support for different workload types  
✅ **Monitoring & Logging** - Cloud Logging and Cloud Monitoring integration  
✅ **Shielded Nodes** - GKE security hardening with secure boot  
✅ **Maintenance Windows** - Scheduled cluster upgrades  
✅ **High Availability** - Regional cluster with multi-zone failover  

## Enterprise Standards Implemented

### Security
- Private GKE cluster with no public node IPs
- Workload Identity for secure pod-to-GCP authentication
- Shielded Nodes (Secure Boot + Integrity Monitoring)
- Network policies for pod-to-pod communication control
- Service account best practices with least privilege

### Reliability
- Regional cluster (multi-zone failover)
- Auto-repair and auto-upgrade enabled
- Scheduled maintenance windows
- Master authorized networks with fine-grained control

### Observability
- Cloud Logging integration (container logs)
- Cloud Monitoring integration (metrics)
- Structured logging with Kubernetes-aware parsing
- Resource labels for cost tracking and organization

### Networking
- VPC Native networking (efficient IP usage)
- Secondary IP ranges for pods and services
- Cloud NAT for private node egress
- Customizable network policies

## Usage

```hcl
module "gke" {
  source = "../../__modules/google-gke-infrastructure"

  # GCP Configuration
  project_id = "my-project"
  region     = "us-central1"

  # Cluster Configuration
  cluster_name       = "my-cluster"
  kubernetes_version = "1.29"  # Empty string for latest
  cluster_location   = "regional"

  # Network Configuration
  network_name          = "my-network"
  network_cidr          = "10.0.0.0/16"
  subnet_primary_cidr   = "10.1.0.0/20"
  enable_private_cluster = true

  # Node Pools
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
    compute = {
      min_node_count = 1
      max_node_count = 10
      machine_type   = "n2-highmem-4"
      disk_size_gb   = 100
      preemptible    = true
      labels = {
        workload = "compute"
      }
    }
  }

  # Features
  enable_workload_identity  = true
  enable_network_policy     = true
  enable_cloud_logging      = true
  enable_cloud_monitoring   = true
  enable_shielded_nodes     = true

  # RBAC
  cluster_admin_users = ["admin@company.com"]
  cluster_edit_users  = ["devops@company.com"]
  cluster_view_users  = ["security@company.com"]

  # Workload Identity Namespaces
  workload_identity_namespaces = ["default", "kube-system", "monitoring"]

  # Labeling
  resource_labels = {
    environment = "production"
    team        = "platform"
    cost-center = "engineering"
  }

  labels = {
    managed-by = "terraform"
    cluster    = "my-cluster"
  }
}
```

## Inputs

### GCP Configuration
- `project_id` - GCP Project ID (required)
- `region` - GCP region (default: us-central1)

### Cluster Configuration
- `cluster_name` - GKE cluster name (required)
- `kubernetes_version` - Kubernetes version, empty for latest (default: "")
- `cluster_location` - "regional" or "zonal" (default: "regional")
- `zones` - Availability zones for zonal clusters (default: [])

### Network Configuration
- `network_name` - VPC network name (required)
- `network_cidr` - VPC CIDR block (default: 10.0.0.0/16)
- `subnet_primary_cidr` - Primary subnet CIDR (default: 10.1.0.0/20)
- `subnet_secondary_ranges` - Pod and service CIDR ranges
- `enable_private_cluster` - Enable private cluster (default: true)
- `enable_network_policy` - Enable Kubernetes network policy (default: true)

### Features & Add-ons
- `enable_http_load_balancing` - Enable load balancing add-on (default: true)
- `enable_network_policy_addon` - Enable network policy add-on (default: true)
- `enable_cloud_logging` - Enable Cloud Logging (default: true)
- `enable_cloud_monitoring` - Enable Cloud Monitoring (default: true)
- `enable_workload_identity` - Enable Workload Identity (default: true)
- `enable_shielded_nodes` - Enable Shielded Nodes (default: true)
- `enable_binary_authorization` - Enable Binary Authorization (default: false)

### Maintenance
- `maintenance_window_day` - Maintenance window day 0-6 (default: 3 = Wednesday)
- `maintenance_window_hour` - Maintenance window hour UTC (default: 2)

### Node Pools
- `node_pools` - Map of node pool configurations (required)
  - `min_node_count` - Minimum nodes (required)
  - `max_node_count` - Maximum nodes (required)
  - `machine_type` - GCP machine type (required)
  - `disk_size_gb` - Node disk size (default: 50)
  - `disk_type` - Disk type (default: pd-standard)
  - `preemptible` - Use preemptible VMs (default: false)
  - `auto_repair` - Auto-repair nodes (default: true)
  - `auto_upgrade` - Auto-upgrade nodes (default: true)
  - `labels` - Node labels (default: {})
  - `taints` - Node taints (default: [])

### Workload Identity
- `workload_identity_enabled` - Enable workload identity (default: true)
- `workload_identity_namespaces` - Namespaces for WI setup (default: ["default", "kube-system"])

### RBAC
- `cluster_admin_users` - Users with admin role (default: [])
- `cluster_edit_users` - Users with edit role (default: [])
- `cluster_view_users` - Users with view role (default: [])

### Labeling
- `labels` - Cluster labels (default: {})
- `resource_labels` - Resource labels (default: {})
- `tags` - Network tags (default: [])

## Outputs

### Cluster
- `cluster_id` - GKE cluster ID
- `cluster_name` - Cluster name
- `cluster_location` - Cluster location
- `cluster_endpoint` - Cluster API endpoint
- `kubernetes_version` - Kubernetes version
- `cluster_ca_certificate` - CA certificate

### Network
- `network_name` - VPC network name
- `network_id` - VPC network ID
- `subnet_name` - Subnet name
- `subnet_id` - Subnet ID
- `subnet_primary_cidr` - Primary CIDR
- `secondary_ranges` - Secondary IP ranges

### Service Accounts
- `cluster_service_account_email` - Cluster service account
- `cluster_service_account_id` - Service account unique ID
- `workload_identity_service_accounts` - Workload Identity service accounts map

### Node Pools
- `node_pool_ids` - Node pool IDs
- `node_pool_names` - Node pool names
- `node_pool_config` - Node pool configuration details

### Workload Identity
- `workload_pool` - Workload pool (project.svc.id.goog)
- `workload_identity_enabled` - Workload Identity status

### Access
- `gke_auth_command` - Command to authenticate with cluster
- `kubeconfig_context` - kubectl context name

### Summary
- `cluster_summary` - Complete cluster configuration

## Getting Started

### 1. Authenticate with GCP
```bash
gcloud auth application-default login
gcloud config set project YOUR_PROJECT_ID
```

### 2. Deploy Cluster
```bash
cd terraform/gke-cluster/example
terraform init
terraform apply
```

### 3. Configure kubectl
```bash
gcloud container clusters get-credentials my-cluster --region us-central1 --project my-project
```

Or use the output from the module:
```bash
eval "$(terraform output -raw gke_auth_command)"
```

## Best Practices

### Security
- Use private clusters in production
- Enable Workload Identity for all pod access to GCP resources
- Implement network policies for pod-to-pod communication
- Enable Binary Authorization for image verification
- Use shielded nodes for enhanced security

### Performance
- Right-size machine types based on workload requirements
- Use preemptible VMs for cost optimization on non-critical workloads
- Configure multiple node pools for different workload types
- Enable cluster auto-scaling for dynamic capacity management

### Cost Optimization
- Use preemptible VMs where fault tolerance allows
- Enable cluster auto-scaling
- Use committed use discounts for stable workloads
- Leverage GKE Autopilot for reduced operational overhead

### Operations
- Monitor cluster and node pool status regularly
- Schedule maintenance windows during low-traffic periods
- Keep Kubernetes version current
- Implement pod disruption budgets for cluster updates

## Architecture Diagram

```
┌─────────────────────────────────────────────┐
│         GCP Project (project_id)            │
├─────────────────────────────────────────────┤
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │     VPC Network (network_name)       │  │
│  │                                      │  │
│  │  ┌─────────────────────────────────┐│  │
│  │  │ Subnet (Primary: subnet_cidr)   ││  │
│  │  │ Secondary Ranges:               ││  │
│  │  │  - Pods (10.4.0.0/14)           ││  │
│  │  │  - Services (10.8.0.0/20)       ││  │
│  │  │                                 ││  │
│  │  │  ┌───────────────────────────┐ ││  │
│  │  │  │  GKE Cluster              │ ││  │
│  │  │  │  (Regional)               │ ││  │
│  │  │  │                           │ ││  │
│  │  │  │  ┌─────────┐┌─────────┐  │ ││  │
│  │  │  │  │ Node    ││ Node    │  │ ││  │
│  │  │  │  │ Pool 1  ││ Pool 2  │  │ ││  │
│  │  │  │  └─────────┘└─────────┘  │ ││  │
│  │  │  │                           │ ││  │
│  │  │  │  Workload Identity        │ ││  │
│  │  │  │  └─ default/wi-sa         │ ││  │
│  │  │  │  └─ kube-system/wi-sa     │ ││  │
│  │  │  └───────────────────────────┘ ││  │
│  │  │                                 ││  │
│  │  │  Cloud NAT (Private Egress)    ││  │
│  │  └─────────────────────────────────┘│  │
│  │                                      │  │
│  └──────────────────────────────────────┘  │
│                                             │
│  Cloud Logging & Monitoring Integration   │
│                                             │
└─────────────────────────────────────────────┘
```

## Module Naming

- **google-gke-cluster** - Component module (creates just the GKE cluster)
- **google-gke-infrastructure** - Stack module (complete VPC + network + GKE + workload identity)

## Support

For issues or questions, refer to:
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Workload Identity Documentation](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
