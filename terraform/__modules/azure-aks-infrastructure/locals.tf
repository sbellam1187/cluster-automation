locals {
  tags = {
    aa-app-shortname    = var.app-shortname
    aa-app-id           = "7466101"
    aa-costcenter       = "0900/1621"
    aa-criticality      = var.aa_criticality
    aa-sdlc-environment = var.app_sdlc_environment == "prod" ? "prod" : "nonprod" # FinOps requires the tags on Azure resources to only indicate if they are "prod" or "nonprod"
    aa-security         = "reserved"
    aa-app-owner        = "258460"
    aa-product          = "Kubernetes as a Service"
  }

  # Logic to determine the managed identity and resource group
  managed_identity = {
    nonprod_nonpci = {
      identity            = "kaas-runway-np-uami",
      resource_group_name = "dx-runway-core-np"
    },
    prod_nonpci = {
      identity            = "kaas-runway-p-uami",
      resource_group_name = "dx-runway-core-prod"
    },
    prod_pci_east = {
      identity            = "kaas-pci-eastus-mi",
      resource_group_name = "dx-runway-core-prod-pci"
    },
    prod_pci_west = {
      identity            = "kaas-pci-westus-mi",
      resource_group_name = "dx-runway-core-prod-pci"
    }
  }[var.pci_cluster ? (var.app_sdlc_environment == "prod" ? (var.location == "eastus" ? "prod_pci_east" : "prod_pci_west") : "nonprod_nonpci") : (var.app_sdlc_environment == "prod" ? "prod_nonpci" : "nonprod_nonpci")]

  managed_identity_id = data.azurerm_user_assigned_identity.dynamic_identity.id

}
