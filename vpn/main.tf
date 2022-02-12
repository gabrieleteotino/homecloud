locals {
  location = "West Europe"
}

module "naming" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["secrets"]
}

data "terraform_remote_state" "bootstrap" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-bootstrap"
    storage_account_name = "stbootstrappv6e"
    container_name       = "tfstate"
    key                  = "bootstrap.tfstate"
  }
}

data "terraform_remote_state" "compute" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-bootstrap"
    storage_account_name = "stbootstrappv6e"
    container_name       = "tfstate"
    key                  = "compute.tfstate"
  }
}

data "azurerm_key_vault" "secrets" {
  name                = data.terraform_remote_state.bootstrap.outputs.keyvault_name
  resource_group_name = data.terraform_remote_state.bootstrap.outputs.resource_group_name
}

data "azurerm_key_vault_secret" "do_token" {
  name         = "DigitalOceanPersonalAccessToken"
  key_vault_id = data.azurerm_key_vault.secrets.id
}

module "wireguard" {
  source               = "./wireguard"
  do_token             = data.azurerm_key_vault_secret.do_token.value
  keyvault_id          = data.azurerm_key_vault.secrets.id
  storage_account_name = data.terraform_remote_state.compute.outputs.storage_account_name
  users                = ["gab-sunzi", "gab-ipad", "gab-phone"]
}