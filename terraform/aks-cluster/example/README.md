# AKS Cluster Example

Production-ready AKS cluster example configuration using the `azure-aks-infrastructure` module.

## Overview

This example demonstrates how to deploy a complete Azure Kubernetes Service (AKS) infrastructure using Terraform. It includes:

- **Complete AKS Cluster** - System and general node pools
- **VNet Networking** - Custom VNets, subnets, route tables, NSGs
- **Workload Identity** - Managed Identity and OIDC issuer
- **Rancher Integration** - Automatic fleet management
- **Vault Integration** - HashiCorp Vault secrets
- **PCI Support** - Optional PCI compliance mode
- **DNS Management** - DNS zone and record configuration
- **Maintenance Windows** - Scheduled cluster and node updates

## Quick Start

### 1. Authenticate with Azure

```bash
az login
az account set --subscription "YOUR_SUBSCRIPTION_ID"
```

### 2. Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars

# Edit with your configuration
vi terraform.tfvars
```

Key values to update:
- `app_archer_id` - Your application ID
- `app-shortname` - Application short name
- `devexp_cluster_name` - Cluster name
- `location` - Azure region (eastus, westus, etc.)
- `ets_vnet_name` - Virtual network name
- `ets_subnet_name` - Subnet name
- `registry_username` - Container registry username
- `registry_password` - Container registry password
- `vault_login_approle_role_id` - Vault AppRole ID
- `vault_login_approle_secret_id` - Vault AppRole secret
- `rancher_token` - Rancher API token

### 3. Configure Backend (Optional)

For remote state, create `backend-config.tfvars`:

```hcl
resource_group_name  = "my-rg"
storage_account_name = "mystg"
container_name       = "terraform"
key                  = "aks/terraform.tfstate"
```

Then initialize with:

```bash
terraform init -backend-config=backend-config.tfvars
```

### 4. Deploy Cluster

```bash
# Validate configuration
terraform validate
terraform plan

# Apply changes
terraform apply
```

### 5. Access Cluster

```bash
# Get kubeconfig
az aks get-credentials \
  --resource-group "$(terraform output -raw dx_resource_group_name)" \
  --name "$(terraform output -raw dx_k8s_cluster_name)"

# Verify connection
kubectl cluster-info
kubectl get nodes
```

## Configuration Examples

### Production Cluster

```hcl
app_sdlc_environment = "prod"
pci_cluster          = false
private_aks          = false

node_vm_size       = "Standard_D8s_v3"
min_node_count     = 3
max_node_count     = 20

general_node_pools = {
  general = {
    vm_size     = "Standard_D8s_v3"
    min_count   = 2
    max_count   = 20
    max_pods    = 110
    priority    = "Regular"
  }
  spot = {
    vm_size     = "Standard_D4s_v3"
    min_count   = 1
    max_count   = 10
    priority    = "Spot"
  }
}

sku_tier     = "Premium"
support_plan = "AKSLongTermSupport"

maintenance_window_auto_upgrade = {
  day_of_week = "Monday"
  start_time  = "02:00"
  duration    = 4
  frequency   = "Weekly"
  interval    = 1
}
```

### Development Cluster

```hcl
app_sdlc_environment = "lab"
pci_cluster          = false
private_aks          = false

node_vm_size       = "Standard_D2s_v3"
min_node_count     = 1
max_node_count     = 5

general_node_pools = {
  general = {
    vm_size     = "Standard_D2s_v3"
    min_count   = 1
    max_count   = 5
    max_pods    = 60
    priority    = "Regular"
  }
}

sku_tier = "Standard"
```

### PCI Cluster

```hcl
pci_cluster = true
location    = "eastus"

outbound_type = "userDefinedRouting"

# PCI-specific networking
legacy_pci_linux_profile = {
  admin_username = "azureuser"
  ssh_key = {
    key_data = "ssh-rsa AAAA..."
  }
}

azuread_rbac = {
  enabled                = true
  managed                = true
  admin_group_object_ids = ["00000000-0000-0000-0000-000000000000"]
}
```

## Advanced Features

### Multiple Node Pools

```hcl
general_node_pools = {
  general = {
    vm_size     = "Standard_D4s_v3"
    min_count   = 1
    max_count   = 10
    max_pods    = 110
    node_labels = { workload = "general" }
  }
  
  compute = {
    vm_size     = "Standard_D16s_v3"
    min_count   = 1
    max_count   = 5
    max_pods    = 60
    node_labels = { workload = "compute" }
  }
  
  spot = {
    vm_size     = "Standard_D4s_v3"
    priority    = "Spot"
    min_count   = 0
    max_count   = 20
    node_labels = { workload = "spot" }
  }
}
```

### Node Pool Taints

```hcl
general_node_pools = {
  gpu = {
    vm_size     = "Standard_NC6s_v3"
    node_taints = [
      "gpu=true:NoSchedule",
      "nvidia.com/gpu=true:NoExecute"
    ]
  }
}
```

### Custom Sysctl Settings

```hcl
general_node_pools = {
  gen01 = {
    vm_size          = "Standard_D8s_v3"
    vm_max_map_count = 262144  # For Elasticsearch
  }
}
```

## Maintenance and Operations

### Upgrade Kubernetes Version

```hcl
kubernetes_version = "1.25.0"
```

Then run:

```bash
terraform plan
terraform apply
```

### Scale Node Pools

```hcl
general_node_pools = {
  general = {
    min_count = 5
    max_count = 30
    # ...
  }
}
```

### Update Rancher Integration

```hcl
enable_rancher_registration = true
devexp_rancher_environment  = "prod"
rancher_token               = "NEW_TOKEN"
```

## Outputs

Key outputs available:

```bash
terraform output dx_k8s_cluster_name          # Cluster name
terraform output dx_resource_group_name       # Resource group
terraform output cluster_fqdn                 # Cluster FQDN
terraform output oidc_issuer_url              # OIDC URL
terraform output rancher_cluster_id           # Rancher cluster ID
```

Get all outputs:

```bash
terraform output -json
```

## Troubleshooting

### Cluster Creation Failed

```bash
# Check resource group
az group show --name "$(terraform output -raw dx_resource_group_name)"

# Check AKS cluster
az aks show --resource-group "$(terraform output -raw dx_resource_group_name)" \
  --name "$(terraform output -raw dx_k8s_cluster_name)"
```

### Cannot Connect to Cluster

```bash
# Refresh kubeconfig
az aks get-credentials --resource-group <rg> --name <cluster-name> --overwrite-existing

# Check connectivity
kubectl cluster-info
kubectl auth can-i create nodes
```

### Vault Connection Issues

```bash
# Test Vault connectivity
curl -k -X POST \
  -d '{"role_id":"YOUR_ROLE_ID","secret_id":"YOUR_SECRET_ID"}' \
  https://vaultcdc.secretmgmt.aa.com/v1/auth/approle/login
```

### Rancher Registration Failed

```bash
# Verify token
curl -k -H "Authorization: Bearer $RANCHER_TOKEN" \
  https://your-rancher-url/v3/clusters
```

## Security Best Practices

✅ **Use Private Clusters** - Set `private_aks = true` in production  
✅ **Enable RBAC** - Use Azure AD RBAC for access control  
✅ **Network Policies** - Implement Kubernetes network policies  
✅ **Pod Identity** - Use workload identity for pod-to-Azure access  
✅ **Secret Management** - Use Vault for sensitive data  
✅ **Service Endpoints** - Restrict access via service endpoints  

## Cost Optimization

- Use spot/preemptible VMs for non-critical workloads
- Enable cluster auto-scaling
- Right-size node VM types based on workload
- Use reserved instances for predictable workloads

## Next Steps

1. Deploy workloads to the cluster
2. Configure CI/CD pipelines
3. Set up monitoring (Azure Monitor, Prometheus)
4. Implement GitOps (Flux, ArgoCD)
5. Configure backup and disaster recovery

## Support

For issues:
- Check Terraform state file: `terraform state show`
- Review Azure activity logs
- Check Rancher fleet cluster status
- Verify Vault connectivity
- Review cluster logs in Azure

## References

- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Module Documentation](../../../__modules/azure-aks-infrastructure/README.md)
