##################################################################################
# RESOURCES
##################################################################################

#App Service with identity enabled
resource "azurerm_app_service" "this" {
  name                = var.app_service_web_name
  location            = var.location
  resource_group_name = var.resource_group_name
  app_service_plan_id = var.app_service_plan_id
  https_only          = true
  site_config {
    cors {
      allowed_origins     = var.SystemAssignedIdentity ? ["http://localhost:4200", "https://${var.CorsOrigin}"] : [""]
      support_credentials = true
    }
    default_documents = [
      "Default.htm",
      "Default.html",
      "Default.asp",
      "index.htm",
      "index.html",
      "iisstart.htm",
      "default.aspx",
      "index.php",
      "hostingstart.html"
    ]
  }

  identity {
    type = "SystemAssigned"
  }
}
