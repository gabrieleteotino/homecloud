module "naming" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["funz"]
}

resource "azurerm_resource_group" "rg" {
  name     = module.naming.resource_group.name
  location = var.location
}

resource "azurerm_storage_account" "st_funz" {
  name                      = module.naming.storage_account.name_unique
  location                  = var.location
  resource_group_name       = azurerm_resource_group.rg.name
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Hot"
  min_tls_version           = "TLS1_2"
  shared_access_key_enabled = true
  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }
}

resource "azurerm_management_lock" "st_lock" {
  name       = "resource-st-funz-lock"
  scope      = azurerm_storage_account.st_funz.id
  lock_level = "CanNotDelete"
  notes      = "Locked. This is a core component."
}


resource "azurerm_app_service_plan" "funz" {
  name                = module.naming.app_service_plan.name_unique
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
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
  location                   = var.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.funz.id
  storage_account_name       = azurerm_storage_account.st_funz.name
  storage_account_access_key = azurerm_storage_account.st_funz.primary_access_key
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