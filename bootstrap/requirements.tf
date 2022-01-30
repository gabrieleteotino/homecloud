terraform {
  required_version = "~> 1.1.4"

  # Uncomment this line if you don't have a backend storage account
  # backend "local" {}
  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.93.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

provider "azurerm" {
  features {
  }
}
