terraform {
  required_version = "~> 1.1.4"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    # azuread = {
    #   source  = "hashicorp/azuread"
    # }
  }
}

provider "azurerm" {
  features {
  }
}
