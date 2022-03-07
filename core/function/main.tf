locals {
  location = data.azurerm_resource_group.core.location
}

module "naming" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["funz"]
}

module "naming_data" {
  source = "github.com/Azure/terraform-azurerm-naming"
  suffix = ["data"]
}

data "azurerm_resource_group" "core" {
  name = var.core_resource_group_name
}

data "azurerm_storage_account" "core" {
  name                = var.core_storage_account_name
  resource_group_name = var.core_resource_group_name
}

data "azurerm_key_vault_secret" "dev_ops_pat_token" {
  name         = "DevOpsPatForAzFunctions"
  key_vault_id = var.bootstrap_key_vault_id
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

resource "azurerm_management_lock" "plan_lock" {
  name       = "resource-plan-funz-lock"
  scope      = azurerm_app_service_plan.funz.id
  lock_level = "CanNotDelete"
  notes      = "Locked. This is a core component."
}

resource "azurerm_storage_account" "funz" {
  name                      = module.naming.storage_account.name_unique
  resource_group_name       = azurerm_resource_group.funz.name
  location                  = azurerm_resource_group.funz.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Hot"
  min_tls_version           = "TLS1_2"
  shared_access_key_enabled = true
  blob_properties {
    versioning_enabled = false
  }
}

resource "azurerm_management_lock" "st_lock" {
  name       = "resource-st-funz-lock"
  scope      = azurerm_storage_account.funz.id
  lock_level = "CanNotDelete"
  notes      = "Locked. This is a core component."
}

resource "azurerm_storage_account" "data" {
  name                      = module.naming_data.storage_account.name_unique
  resource_group_name       = azurerm_resource_group.funz.name
  location                  = azurerm_resource_group.funz.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Hot"
  min_tls_version           = "TLS1_2"
  shared_access_key_enabled = true
  blob_properties {
    versioning_enabled = false
  }
}

resource "azurerm_storage_container" "pipeline_updates" {
  name                  = "pipeline-updates"
  storage_account_name  = azurerm_storage_account.data.name
  container_access_type = "private"
}

resource "azurerm_management_lock" "st_data_lock" {
  name       = "resource-st-data-lock"
  scope      = azurerm_storage_account.data.id
  lock_level = "CanNotDelete"
  notes      = "Locked. This is a core component."
}

resource "azurerm_function_app" "funz" {
  name                       = module.naming.function_app.name_unique
  location                   = local.location
  resource_group_name        = azurerm_resource_group.funz.name
  app_service_plan_id        = azurerm_app_service_plan.funz.id
  storage_account_name       = azurerm_storage_account.funz.name
  storage_account_access_key = azurerm_storage_account.funz.primary_access_key
  https_only                 = true
  version                    = "~4"
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME        = "dotnet",
    WEBSITE_RUN_FROM_PACKAGE        = 1,
    WEBSITE_ENABLE_SYNC_UPDATE_SITE = "true",
    DataStorage                     = azurerm_storage_account.data.primary_connection_string
    # CoreStorageAccount       = data.azurerm_storage_account.core.name
    DevOpsPat = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault_secret.dev_ops_pat_token.id})"
  }
  site_config {
    always_on     = false
    http2_enabled = true
  }
}

resource "azurerm_management_lock" "func_lock" {
  name       = "resource-func-funz-lock"
  scope      = azurerm_function_app.funz.id
  lock_level = "CanNotDelete"
  notes      = "Locked. This is a core component."
}

# Workaround this will force the keyvault access policy to wait for the function app
# to be updated before trying to read the identity.
data "azurerm_function_app" "funz" {
  name                = azurerm_function_app.funz.name
  resource_group_name = azurerm_function_app.funz.resource_group_name
}

resource "azurerm_key_vault_access_policy" "funz" {
  key_vault_id = var.bootstrap_key_vault_id
  tenant_id    = data.azurerm_function_app.funz.identity.0.tenant_id
  object_id    = data.azurerm_function_app.funz.identity.0.principal_id

  secret_permissions = [
    "Get",
  ]
}

module "github-action" {
  source             = "../modules/github-action"
  repository         = "homecloud_function"
  application_name   = "GitHub Action CI Homecloud Funz"
  target_resource_id = azurerm_function_app.funz.id
}