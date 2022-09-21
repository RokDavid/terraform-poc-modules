output "azurerm_app_default_site_hostname" {
  value = azurerm_app_service.this.default_site_hostname
}

output "azurerm_app_identity_principal_id" {
  value = azurerm_app_service.this.identity.0.principal_id
}
