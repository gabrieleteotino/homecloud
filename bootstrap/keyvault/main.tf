module "naming" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["secrets"]
  unique-seed = "xuk1pngj6h8mzkat1mwr2equqtcdyv0pobl3cu67d35dkx92wmtvfbp70deva"
}

data "azurerm_resource_group" "rg_bootstrap" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "secrets" {
  name                        = module.naming.key_vault.name_unique
  location                    = data.azurerm_resource_group.rg_bootstrap.location
  resource_group_name         = data.azurerm_resource_group.rg_bootstrap.name
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
  name       = "resource-kv-secrets-lock"
  scope      = azurerm_key_vault.secrets.id
  lock_level = "CanNotDelete"
  notes      = "Locked because it's needed for multiple services"
}
