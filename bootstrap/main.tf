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

module "storage" {
  source               = "./storage"
  location             = local.location
  storage_account_name = module.naming.storage_account.name_unique
  resource_group_name  = azurerm_resource_group.rg_bootstrap.name
}

moved {
  from = azurerm_storage_account.st_bootstrap
  to   = module.storage.azurerm_storage_account.st_bootstrap
}

moved {
  from = azurerm_management_lock.st_lock
  to   = module.storage.azurerm_management_lock.st_lock
}

moved {
  from = azurerm_storage_container.tfstate
  to   = module.storage.azurerm_storage_container.tfstate
}