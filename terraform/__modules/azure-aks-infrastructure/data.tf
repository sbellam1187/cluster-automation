# Fetch user assigned identity for the cluster
data "azurerm_user_assigned_identity" "dynamic_identity" {
  name                = local.managed_identity.identity
  resource_group_name = local.managed_identity.resource_group_name
}


data "azurerm_public_ip_prefix" "dx_external_ip_prefix" {
  count               = var.pci_cluster ? 0 : 1
  name                = var.app_sdlc_environment == "prod" ? "dxclusters-externalips-prod-${var.location}" : "dxclusters-externalips-nonprod-${var.location}"
  resource_group_name = var.cluster_resource_group_name
}

### Below are DNS data sources ###
## Fetch K8s cluster details
data "azurerm_kubernetes_cluster" "runway_ok8" {
  count               = (var.pci_cluster || var.private_aks) ? 1 : 0
  name                = "${var.devexp_cluster_name}-${var.devexp_cluster_num}-${var.location}"
  resource_group_name = var.asset_resource_group_name

  depends_on = [azurerm_kubernetes_cluster.runway_ok8]
}

# Get the K8s IP for the private endpoint
data "azurerm_private_endpoint_connection" "pci_cluster_pe" {
  count               = (var.pci_cluster || var.private_aks) ? 1 : 0
  name                = "kube-apiserver"
  resource_group_name = "mc_${var.asset_resource_group_name}_${var.devexp_cluster_name}-${var.devexp_cluster_num}-${var.location}_${var.location}"

  depends_on = [azurerm_kubernetes_cluster.runway_ok8]
}

# Fetch Project42 API token from Vault
data "vault_generic_secret" "p42_password" {
  count    = var.pci_cluster ? 1 : 0
  provider = vault.KaaS
  path     = "secrets/bootstrap/k8s/global/PROJECT42_API_TOKEN"
}

### Below are network data sources ###

# Fetch the existing NSG for non-PCI clusters
data "azurerm_network_security_group" "non_pci_nsg" {
  count               = var.pci_cluster && var.app_sdlc_environment == "prod" ? 0 : 1
  name                = "default-nsg-${var.location}"
  resource_group_name = var.cluster_resource_group_name
}

# Fetch the existing NSG for PCI clusters in production environment
data "azurerm_network_security_group" "pci_nsg" {
  count               = var.pci_cluster && var.app_sdlc_environment == "prod" ? 1 : 0
  name                = "default-nsg-pci-${var.location}"
  resource_group_name = var.pci_resource_group
}
data "azurerm_user_assigned_identity" "workload-identity" {
  name                = "workload-identity-${var.app_sdlc_environment}-${var.location}-mi"
  resource_group_name = var.pci_cluster && var.app_sdlc_environment == "prod" ? var.pci_resource_group : var.asset_resource_group_name
}


##Create a federated identity credential
resource "azurerm_federated_identity_credential" "workload_identity" {
  name                = "fed-identity-${var.app_sdlc_environment}-${var.devexp_cluster_num}-${var.location}"
  resource_group_name = var.pci_cluster && var.app_sdlc_environment == "prod" ? var.pci_resource_group : var.asset_resource_group_name
  parent_id           = data.azurerm_user_assigned_identity.workload-identity.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.runway_ok8.oidc_issuer_url
  subject             = "system:serviceaccount:container-registry-update:container-registry-update-sa"
}
