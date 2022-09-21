output "mssql_server_id" {
  value = azurerm_mssql_server.mssql_server.id
}

output "fully_qualified_domain_name" {
  value = azurerm_mssql_server.mssql_server.fully_qualified_domain_name
}

output "mssql_server_administrator_login" {
  value     = random_string.administrator_login.result
  sensitive = false
}

output "mssql_server_administrator_login_password" {
  value     = random_password.administrator_login_password.result
  sensitive = true
}
