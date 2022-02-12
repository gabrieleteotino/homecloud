data "azurerm_resource_group" "core" {
  name = var.core_resource_group_name
}

resource "azurerm_storage_account" "core" {
  name                      = var.core_storage_account_name
  resource_group_name       = data.azurerm_resource_group.core.name
  location                  = data.azurerm_resource_group.core.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Hot"
  min_tls_version           = "TLS1_2"
  shared_access_key_enabled = true
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }
}

resource "azurerm_management_lock" "st_lock" {
  name       = "resource-storage-lock"
  scope      = azurerm_storage_account.core.id
  lock_level = "CanNotDelete"
  notes      = "Locked. This is a core component."
}
