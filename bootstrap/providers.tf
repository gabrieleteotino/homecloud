terraform {
  required_version = "~> 1.1.4"

  # Uncomment this line if you don't have a backend storage account e.g in case of first run
  # backend "local" {}
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    azuread = {
      source = "hashicorp/azuread"
    }
  }
}

provider "azurerm" {
  features {
  }
}
