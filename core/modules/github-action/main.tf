# Application

resource "azuread_application" "this" {
  display_name = var.application_name
}

resource "azuread_application_password" "this" {
  application_object_id = azuread_application.this.id
}

# Service principal

resource "azuread_service_principal" "this" {
  application_id = azuread_application.this.application_id
}

resource "azurerm_role_assignment" "this" {
  scope                = var.target_resource_id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.this.object_id
}

# GitHub secrets

resource "github_actions_secret" "terraform" {
  repository      = var.repository
  secret_name     = "AZURE_CREDENTIALS"
  plaintext_value = <<-EOT
{
  "clientId": "${azuread_application.this.application_id}",
  "clientSecret": "${azuread_application_password.this.value}",
  "subscriptionId": "${data.azurerm_subscription.current.subscription_id}",
  "tenantId": "${data.azuread_client_config.current.tenant_id}",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
EOT
}

resource "github_actions_secret" "arm_client_id" {
  repository      = var.repository
  secret_name     = "ARM_CLIENT_ID"
  plaintext_value = azuread_application.this.application_id
}

resource "github_actions_secret" "arm_client_secret" {
  repository      = var.repository
  secret_name     = "ARM_CLIENT_SECRET"
  plaintext_value = azuread_application_password.this.value
}

resource "github_actions_secret" "arm_subscription_id" {
  repository      = var.repository
  secret_name     = "ARM_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.current.subscription_id
}

resource "github_actions_secret" "arm_tenant_id" {
  repository      = var.repository
  secret_name     = "ARM_TENANT_ID"
  plaintext_value = data.azuread_client_config.current.tenant_id
}