module "naming" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["core"]
}

resource "azurerm_resource_group" "core" {
  name     = module.naming.resource_group.name
  location = var.location
}

data "azurerm_resources" "bootstrap_key_vault" {
  resource_group_name = "rg-bootstrap"
  type                = "Microsoft.KeyVault/vaults"
}

locals {
  key_vault_id = data.azurerm_resources.bootstrap_key_vault.resources[0].id
}

module "storage" {
  source                    = "./storage"
  core_resource_group_name  = azurerm_resource_group.core.name
  core_storage_account_name = module.naming.storage_account.name_unique
  #key_vault_id = data.azurerm_key_vault.secrets.id
  depends_on = [
    azurerm_resource_group.core
  ]
}

module "function" {
  source                    = "./function"
  core_resource_group_name  = azurerm_resource_group.core.name
  core_storage_account_name = module.naming.storage_account.name_unique
  bootstrap_key_vault_id    = local.key_vault_id
  depends_on = [
    azurerm_resource_group.core,
    module.storage
  ]
}
