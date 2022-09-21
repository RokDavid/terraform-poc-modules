##################################################################################
# RESOURCES
##################################################################################

resource "random_string" "administrator_login" {
  length  = 12
  special = true
}

resource "random_password" "administrator_login_password" {
  length  = 15
  special = true
}

#SQL Server
resource "azurerm_mssql_server" "mssql_server" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = random_string.administrator_login.result
  administrator_login_password = random_password.administrator_login_password.result
}

resource "azurerm_sql_firewall_rule" "AllowAzureResources" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = azurerm_mssql_server.mssql_server.resource_group_name
  server_name         = azurerm_mssql_server.mssql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}
