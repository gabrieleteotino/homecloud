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