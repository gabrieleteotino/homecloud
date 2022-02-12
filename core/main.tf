module "naming" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["core"]
}

resource "azurerm_resource_group" "core" {
  name     = module.naming.resource_group.name
  location = var.location
}

module "keyvault" {
  source                   = "./keyvault"
  core_resource_group_name = azurerm_resource_group.core.name
  core_keyvault_name       = module.naming.key_vault.name_unique
  depends_on = [
    azurerm_resource_group.core
  ]
}

module "storage" {
  source                    = "./storage"
  core_resource_group_name  = azurerm_resource_group.core.name
  core_storage_account_name = module.naming.storage_account.name_unique
  #key_vault_id = data.azurerm_key_vault.secrets.id
  depends_on = [
    azurerm_resource_group.core,
    module.keyvault
  ]
}

module "function" {
  source                    = "./function"
  core_resource_group_name  = azurerm_resource_group.core.name
  core_storage_account_name = module.naming.storage_account.name_unique
  core_key_vault_id         = module.keyvault.id
  depends_on = [
    azurerm_resource_group.core,
    module.storage
  ]
}
