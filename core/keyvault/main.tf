data "azurerm_resource_group" "core" {
  name = var.core_resource_group_name
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "core" {
  name                        = var.core_keyvault_name
  location                    = data.azurerm_resource_group.core.location
  resource_group_name         = data.azurerm_resource_group.core.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = true
  soft_delete_retention_days  = 90

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "Create", "List"
    ]

    secret_permissions = [
      "Get", "Set", "List"
    ]

    storage_permissions = [
      "Get", "Set", "List"
    ]
  }
}

resource "azurerm_management_lock" "kv_lock" {
  name       = "resource-kv-core-lock"
  scope      = azurerm_key_vault.core.id
  lock_level = "CanNotDelete"
  notes      = "Locked because it's needed for multiple services"
}
