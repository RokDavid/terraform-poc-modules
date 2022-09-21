##################################################################################
# RESOURCES
##################################################################################

resource "azurerm_storage_container" "imagesContainer" {
  name                  = var.name
  storage_account_name  = var.storage_account_name
  container_access_type = var.container_access_type
}
