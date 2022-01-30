data "azurerm_resource_group" "rg_bootstrap" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "st_bootstrap" {
  name                      = var.storage_account_name
  location                  = data.azurerm_resource_group.rg_bootstrap.location
  resource_group_name       = data.azurerm_resource_group.rg_bootstrap.name
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
  scope      = azurerm_storage_account.st_bootstrap.id
  lock_level = "CanNotDelete"
  notes      = "Locked because it's needed for terraform"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.st_bootstrap.name
  container_access_type = "private"
}