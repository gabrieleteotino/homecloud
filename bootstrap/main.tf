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
  resource_group_name  = azurerm_resource_group.rg_bootstrap.name
  storage_account_name = module.naming.storage_account.name_unique
}

module "keyvault" {
  source              = "./keyvault"
  resource_group_name = azurerm_resource_group.rg_bootstrap.name
}
