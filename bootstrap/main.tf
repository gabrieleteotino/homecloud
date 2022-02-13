locals {
  location = "West Europe"
}

module "naming" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["bootstrap"]
}

module "naming_secret" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["secret"]
}

resource "azurerm_resource_group" "bootstrap" {
  name     = module.naming.resource_group.name
  location = local.location
}

resource "azurerm_storage_account" "bootstrap" {
  name                      = module.naming.storage_account.name_unique
  location                  = azurerm_resource_group.bootstrap.location
  resource_group_name       = azurerm_resource_group.bootstrap.name
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  access_tier               = "Cool"
  shared_access_key_enabled = true
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 365
    }
    container_delete_retention_policy {
      days = 365
    }
  }
}

resource "azurerm_management_lock" "st_lock" {
  name       = "resource-st-bootstap-lock"
  scope      = azurerm_storage_account.bootstrap.id
  lock_level = "CanNotDelete"
  notes      = "Locked because it's needed for terraform"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.bootstrap.name
  container_access_type = "private"
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "secret" {
  name                        = module.naming_secret.key_vault.name_unique
  location                    = azurerm_resource_group.bootstrap.location
  resource_group_name         = azurerm_resource_group.bootstrap.name
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
      "Get", "Set", "List", "Delete"
    ]

    storage_permissions = [
      "Get", "Set", "List"
    ]
  }
}

resource "azurerm_management_lock" "kv_lock" {
  name       = "resource-kv-secret-lock"
  scope      = azurerm_key_vault.secret.id
  lock_level = "CanNotDelete"
  notes      = "Locked because it's needed for multiple services"
}