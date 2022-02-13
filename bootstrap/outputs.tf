output "resource_group_name" {
  value = azurerm_resource_group.bootstrap.name
}

output "storage_account_name" {
  value = azurerm_storage_account.bootstrap.name
}

output "key_vault_id" {
  value = azurerm_key_vault.secret.id
}

output "key_vault_name" {
  value = azurerm_key_vault.secret.name
}