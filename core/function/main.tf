locals {
  location = data.azurerm_resource_group.core.location
}

module "naming" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["funz"]
}

data "azurerm_resource_group" "core" {
  name = var.core_resource_group_name
}

data "azurerm_storage_account" "core" {
  name                = var.core_storage_account_name
  resource_group_name = var.core_resource_group_name
}

resource "azurerm_resource_group" "funz" {
  name     = module.naming.resource_group.name
  location = local.location
}

resource "azurerm_app_service_plan" "funz" {
  name                = module.naming.app_service_plan.name_unique
  location            = local.location
  resource_group_name = azurerm_resource_group.funz.name
  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_management_lock" "appi_lock" {
  name       = "resource-appi-funz-lock"
  scope      = azurerm_app_service_plan.funz.id
  lock_level = "CanNotDelete"
  notes      = "Locked. This is a core component."
}

resource "azurerm_function_app" "funz" {
  name                       = module.naming.function_app.name_unique
  location                   = local.location
  resource_group_name        = azurerm_resource_group.funz.name
  app_service_plan_id        = azurerm_app_service_plan.funz.id
  storage_account_name       = data.azurerm_storage_account.core.name
  storage_account_access_key = data.azurerm_storage_account.core.primary_access_key
  https_only                 = true
  version                    = "~4"
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet",
  }
  site_config {
    always_on     = false
    http2_enabled = true
  }
}

resource "azurerm_management_lock" "func_lock" {
  name       = "resource-funz-lock"
  scope      = azurerm_function_app.funz.id
  lock_level = "CanNotDelete"
  notes      = "Locked. This is a core component."
}