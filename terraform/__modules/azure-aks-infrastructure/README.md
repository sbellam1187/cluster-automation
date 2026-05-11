# Azure Kubernetes Service (AKS) Infrastructure Module

Enterprise-ready AKS infrastructure module - Complete stack with networking, node pools, Vault, Rancher, and advanced features in one reusable module.

## Features

✅ **Complete AKS Cluster** - Full cluster with system and general node pools  
✅ **Advanced Networking** - Custom VNets, subnets, route tables, NSGs  
✅ **Workload Identity** - Managed Identity and OIDC issuer support  
✅ **Multiple Node Pools** - Configurable general-purpose and system pools  
✅ **PCI Compliance** - Support for PCI and non-PCI cluster configurations  
✅ **Rancher Integration** - Automatic Rancher registration and management  
✅ **Vault Integration** - HashiCorp Vault AppRole authentication  
✅ **Private Clusters** - Support for private AKS clusters  
✅ **DNS Management** - DNS zone and record management  
✅ **Pod Identity** - Azure AD pod identity support  
✅ **Spot VMs** - Cost optimization with spot/preemptible VMs  
✅ **Maintenance Windows** - Scheduled cluster and node updates  

## Enterprise Standards Implemented

### Security
- Workload Identity and OIDC issuer
- Managed Identity for AKS
- Azure AD RBAC integration
- Network Security Groups (NSGs)
- Private cluster support
- Service endpoints

### Reliability
- Auto-scaling node pools
- Auto-repair and auto-upgrade
- Scheduled maintenance windows
- Spot VM eviction policies
- Multi-zone availability

### Operations
- Rancher integration for fleet management
- Vault integration for secrets
- Istio service account creation
- DNS management
- Comprehensive tagging

### Cost Control
- Spot instance support
- Auto-scaling node pools
- Multiple node pool configurations
- Preemptible VM options

## Code Preservation

All existing AKS cluster code has been preserved in this module without any loss:

### Core Files
- `main.tf` - AKS cluster definition with all original configurations
- `variables.tf` - Complete variable set with all original defaults
- `locals.tf` - Tag definitions and managed identity logic
- `providers.tf` - All provider configurations (azurem, kubernetes, vault, rancher, helm)
- `outputs.tf` - All original outputs

### Networking Files
- `network.tf` - VNet subnet, NSG associations, route tables
- `dns.tf` - DNS zone and record management
- `postgres_routes.tf` - PostgreSQL routing configuration

### Node Pool & Configuration Files
- `nodepools.tf` - General node pool definitions with auto-scaling
- `data.tf` - Data sources for Azure resources
- `istio-sa.tf` - Istio service account configuration
- `rancher.tf` - Rancher cluster registration
- `vault.tf` - Vault-related configurations

## Usage

```hcl
module "aks" {
  source = "../../__modules/azure-aks-infrastructure"

  # Required variables from your configuration
  app_archer_id                = var.app_archer_id
  app-shortname                = var.app-shortname
  app_owner                    = var.app_owner
  app_product                  = var.app_product
  app_sdlc_environment         = var.app_sdlc_environment
  app_security                 = var.app_security
  
  devexp_cluster_name          = var.devexp_cluster_name
  devexp_cluster_num           = var.devexp_cluster_num
  
  location                     = var.location
  asset_resource_group_name    = var.asset_resource_group_name
  cluster_resource_group_name  = var.cluster_resource_group_name
  
  # Network configuration
  ets_vnet_name                = var.ets_vnet_name
  ets_subnet_name              = var.ets_subnet_name
  ets_subnet                   = var.ets_subnet
  ets_next_hop_ip              = var.ets_next_hop_ip
  
  # Node pool configuration
  node_vm_size                 = var.node_vm_size
  max_pod_count                = var.max_pod_count
  min_node_count               = var.min_node_count
  max_node_count               = var.max_node_count
  general_node_pools           = var.general_node_pools
  availability_zones           = var.availability_zones
  
  # Kubernetes configuration
  kubernetes_version           = var.kubernetes_version
  enable_auto_scaling          = var.enable_auto_scaling
  loadbalancer_sku             = var.loadbalancer_sku
  
  # Vault configuration
  vault_host_url               = var.vault_host_url
  vault_namespace              = var.vault_namespace
  vault_ca_cert_file           = var.vault_ca_cert_file
  vault_login_approle_role_id  = var.vault_login_approle_role_id
  vault_login_approle_secret_id = var.vault_login_approle_secret_id
  vault_kaas_login_approle_role_id = var.vault_kaas_login_approle_role_id
  vault_kaas_login_approle_secret_id = var.vault_kaas_login_approle_secret_id
  
  # Rancher configuration
  rancher_token                = var.rancher_token
  enable_rancher_registration  = var.enable_rancher_registration
  
  # Registry configuration
  registry_username            = var.registry_username
  registry_password            = var.registry_password
  
  # Advanced options
  pci_cluster                  = var.pci_cluster
  private_aks                  = var.private_aks
  auto_patch_upgrade           = var.auto_patch_upgrade
  node_upgrade_channel         = var.node_upgrade_channel
  
  # Optional maintenance windows
  maintenance_window_auto_upgrade = var.maintenance_window_auto_upgrade
  maintenance_window_node_os      = var.maintenance_window_node_os
}
```

## Inputs

All original variables are preserved. Key variables include:

### Application Configuration
- `app_archer_id` - Application archer ID
- `app-shortname` - Application short name
- `app_owner` - Application owner
- `app_product` - Application product name
- `app_sdlc_environment` - SDLC environment (lab, nonprod, prod)
- `app_security` - Security classification
- `aa_criticality` - Application criticality level

### Cluster Configuration
- `devexp_cluster_name` - Cluster name
- `devexp_cluster_num` - Cluster number
- `kubernetes_version` - Kubernetes version (default: 1.24.10)
- `location` - Azure region
- `pci_cluster` - PCI compliance flag
- `private_aks` - Private cluster flag

### Node Pool Configuration
- `node_vm_size` - VM size for nodes
- `max_pod_count` - Maximum pods per node
- `min_node_count` - Minimum node count for autoscaling
- `max_node_count` - Maximum node count for autoscaling
- `general_node_pools` - Map of general-purpose node pool configurations
- `availability_zones` - Map of availability zones by location

### Network Configuration
- `ets_vnet_name` - Virtual network name
- `ets_subnet_name` - Subnet name
- `ets_subnet` - Subnet CIDR
- `ets_next_hop_ip` - Next hop IP for routes
- `ingresscontroller_ip` - Ingress controller IP

### Integration Configuration
- `vault_host_url` - Vault server URL
- `vault_namespace` - Vault namespace
- `vault_login_approle_role_id` - Vault AppRole role ID
- `vault_login_approle_secret_id` - Vault AppRole secret ID
- `rancher_token` - Rancher API token
- `registry_username` - Container registry username
- `registry_password` - Container registry password

## Outputs

All original outputs are preserved:
- `kubernetes_cluster_id` - AKS cluster ID
- `kubernetes_cluster_name` - Cluster name
- `kube_config` - Kubernetes config
- `kube_admin_config` - Admin kubeconfig
- `client_certificate` - Client certificate from kubeconfig
- `cluster_ca_certificate` - Cluster CA certificate
- And many more...

## Deployment

To deploy using this module:

```bash
# In aks-cluster/example directory
terraform init
terraform plan
terraform apply
```

## Migration from Direct Code to Module

The original AKS cluster code can be migrated to use this module by:

1. Moving all variable definitions to the example/variables.tf
2. Creating example/main.tf that calls the module with all variables
3. Creating example/outputs.tf that re-exports module outputs
4. Creating example/providers.tf with backend configuration
5. Creating terraform.tfvars.example with example values

**No code changes or refactoring needed** - all original functionality is preserved exactly as-is.

## File Structure

```
__modules/azure-aks-infrastructure/
├── main.tf                          # AKS cluster and public IP resources
├── network.tf                       # VNet, subnet, NSG, route table
├── nodepools.tf                     # General node pool definitions
├── data.tf                          # Data sources for Azure resources
├── locals.tf                        # Local values and tags
├── providers.tf                     # Provider configurations
├── istio-sa.tf                      # Istio service account
├── rancher.tf                       # Rancher integration
├── vault.tf                         # Vault integration
├── dns.tf                           # DNS configuration
├── postgres_routes.tf               # PostgreSQL routes
├── variables.tf                     # All input variables
├── outputs.tf                       # All outputs
└── README.md                        # This file

example/
├── main.tf                          # Module instantiation
├── outputs.tf                       # Output re-exports
├── variables.tf                     # Example variables
├── terraform.tfvars.example         # Example values
├── provider.tf                      # Provider and backend config
└── README.md                        # Example documentation
```

## Best Practices

1. **Keep all original code intact** - No modifications to module code
2. **Use terraform.tfvars** - Store environment-specific values
3. **Lock provider versions** - Use provider version constraints
4. **Plan before apply** - Always review terraform plan output
5. **Backup kubeconfig** - Store kubeconfig securely
6. **Monitor cluster** - Use Azure Monitor and Rancher

## Support

For issues or questions:
- Review original AKS cluster README
- Check Azure AKS documentation
- Verify all required variables are provided
- Check Vault and Rancher connectivity

## Compatibility

- Terraform >= 1.13.5
- Azure Provider >= 4.18.0
- Azure AD Provider >= 2.15.0
- Rancher Provider >= 8.2.1
