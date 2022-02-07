module "naming" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["core"]
}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name
  location = var.location
}

resource "azurerm_storage_account" "storage" {
  name                      = module.naming.storage_account.name_unique
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
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
  scope      = azurerm_storage_account.storage.id
  lock_level = "CanNotDelete"
  notes      = "Locked. This is a core component."
}
