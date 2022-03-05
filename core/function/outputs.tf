output "identity_tenant_id" {
  value = azurerm_function_app.funz.identity.0.tenant_id
}

output "identity_principal_id" {
  value = azurerm_function_app.funz.identity.0.principal_id
}
