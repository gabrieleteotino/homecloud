
output "resource_group_name" {
  value = azurerm_resource_group.rg_bootstrap.name
}

output "storage_account_name" {
  value = azurerm_storage_account.st_bootstrap.name
}

