output "storage_account_connectionstring" {
  description = "storageAccountConnectionString"
  value       = azurerm_storage_account.storageAccount.primary_connection_string
}

output "storage_account_name" {
  description = "storageAccountName"
  value       = azurerm_storage_account.storageAccount.name
}
