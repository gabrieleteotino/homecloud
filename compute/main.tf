
data "terraform_remote_state" "bootstrap" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-bootstrap"
    storage_account_name = "stbootstrappv6e"
    container_name       = "tfstate"
    key                  = "bootstrap.tfstate"
  }
}

data "azurerm_key_vault" "secrets" {
  name                = data.terraform_remote_state.bootstrap.outputs.keyvault_name
  resource_group_name = data.terraform_remote_state.bootstrap.outputs.resource_group_name
}

module "function" {
  source       = "./function"
  key_vault_id = data.azurerm_key_vault.secrets.id
}