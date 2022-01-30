
output "resource_group_name" {
  value = azurerm_resource_group.rg_bootstrap.name
}

output "storage_account_name" {
  value = module.storage.storage_account_name
}

output "keyvault_name" {
  value = module.keyvault.keyvault_name
}