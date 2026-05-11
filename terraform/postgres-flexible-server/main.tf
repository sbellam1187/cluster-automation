data "azurerm_client_config" "current" {}

module "keyvault" {
  source              = "git::https://github.com/AAInternal/terraform.git//azure-modules/keyvault?ref=keyvault-v3.0.1"
  keyvault_name       = var.keyvault_name
  resource_group_name = var.resource_group_name
  keyvault_sku        = "standard"
  access_policy = [
    {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = data.azurerm_client_config.current.object_id
      key_permissions = [
        "Get", "List", "Create", "Delete"
      ]

      secret_permissions = [
        "Get", "List", "Set", "Delete", "Recover"
      ]

      storage_permissions = [
        "Get", "List", "Set", "Delete"
      ]

      certificate_permissions = [
        "Get", "List", "Create", "Delete"
      ]
    }
  ]
}

module "simple_postgres_database" {
  source                  = "git::https://github.com/AAInternal/terraform.git//azure-modules/postgresql-flexible-server?ref=postgresql-flexible-server-v2.1.1"
  server_name             = var.server_name
  resource_group_name     = var.resource_group_name
  sku_name                = var.sku_name
  database_version        = var.database_version
  admin_username          = var.admin_username
  user_supplied_pw        = var.user_supplied_pw
  postgresql_db_name      = var.postgresql_db_name
  postgresql_db_charset   = var.postgresql_db_charset
  postgresql_db_collation = var.postgresql_db_collation
  storage_mb              = var.storage_mb
  keyvault_name           = module.keyvault.key_vault_name
  vnet_name               = var.vnet_name
  snet_name               = var.snet_name
  vnet_primary_rg_name    = var.vnet_primary_rg_name
  high_availability       = var.high_availability
  create_mode             = var.create_mode
  providers = {
    azurerm.aa-ets-hub = azurerm.aa-ets-hub
    azurerm.default    = azurerm
    azuread.default    = azuread
    vault.default      = vault
  }
  depends_on = [
    module.keyvault
  ]
}
