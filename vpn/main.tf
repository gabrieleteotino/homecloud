data "azurerm_resources" "core_keyvault" {
  resource_group_name = "rg-core"
  type                = "Microsoft.KeyVault/vaults"
}

data "azurerm_resources" "core_storage" {
  resource_group_name = "rg-core"
  type                = "Microsoft.Storage/storageAccounts"
}

data "azurerm_key_vault_secret" "do_token" {
  name         = "DigitalOceanPersonalAccessToken"
  key_vault_id = data.azurerm_resources.core_keyvault.resources[0].id
}

module "wireguard" {
  source               = "./wireguard"
  do_token             = data.azurerm_key_vault_secret.do_token.value
  keyvault_id          = data.azurerm_resources.core_keyvault.resources[0].id
  storage_account_name = data.azurerm_resources.core_storage.resources[0].name
  users                = ["gab-sunzi", "gab-ipad", "gab-phone"]
}