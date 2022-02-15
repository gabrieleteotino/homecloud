terraform {
  required_version = "~> 1.1.4"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }

    azuread = {
      source = "hashicorp/azuread"
    }

    github = {
      source = "integrations/github"
    }
  }
}

provider "azurerm" {
  features {
  }
}

provider "github" {
  token = var.github_token
  owner = "gabrieleteotino"
}