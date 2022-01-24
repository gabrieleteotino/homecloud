locals {
  location = "West Europe"
}

module "naming" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["bootstrap"]
}

resource "azurerm_resource_group" "rg_bootstrap" {
  name     = module.naming.resource_group.name
  location = local.location
}

resource "azurerm_storage_account" "st_bootstrap" {
  name                      = module.naming.storage_account.name
  location                  = local.location
  resource_group_name       = azurerm_resource_group.rg_bootstrap.name
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  access_tier               = "Cool"
  shared_access_key_enabled = false
}


resource "azurerm_management_lock" "st_lock" {
  name       = "resource-st-bootstap-lock"
  scope      = azurerm_storage_account.st_bootstrap.id
  lock_level = "CanNotDelete"
  notes      = "Locked because it's needed for terraform"
}