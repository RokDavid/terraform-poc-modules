##################################################################################
# PROVIDERS / BACKEND
##################################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.1.0"
    }
  }
}

terraform {
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

##################################################################################
# LOCALS
##################################################################################

locals {
  env_tags = {
    "env" = "${var.PREFIX}"
  }
}

##################################################################################
# DATA
##################################################################################


data "azurerm_client_config" "current" {}


##################################################################################
# RESOURCES
##################################################################################

#RG
resource "azurerm_resource_group" "rg" {
  name     = "${var.RESOURCE_GROUP_NAME}-${var.PREFIX}"
  location = var.LOCATION
}

##################################################################################
### App Service Plan
module "app_service_plan" {
  source                = "./modules/app_service_plan_module"
  app_service_plan_name = "${var.PREFIX}-${var.APP_SERVICE_PLAN_NAME}"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  sku_tier              = var.SKU_TIER
  sku_size              = var.SKU_SIZE
  depends_on = [
    azurerm_resource_group.rg
  ]
}

##################################################################################
### Apps
module "app_service_frontend" {
  ### if var.Env is not prod, apply specific naming
  source               = "./modules/app_service_module"
  app_service_web_name = var.ENV == "prod" ? var.APP_SERVICE_NAME : "${var.PREFIX}-${var.APP_SERVICE_NAME}"
  resource_group_name  = azurerm_resource_group.rg.name
  location             = azurerm_resource_group.rg.location
  app_service_plan_id  = module.app_service_plan.appServicePlanId
}


module "app_service_backend" {
  source                 = "./modules/app_service_module"
  app_service_web_name   = "${var.APP_SERVICE_BACKEND_NAME}-${var.PREFIX}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  app_service_plan_id    = module.app_service_plan.appServicePlanId
  SystemAssignedIdentity = true
  CorsOrigin             = module.app_service_frontend.azurerm_app_default_site_hostname
  depends_on = [
    module.app_service_frontend
  ]
}

##################################################################################
### SQLs 

#Server
module "mssql_server" {
  source              = "./modules/mssql_server_module"
  name                = "${var.PREFIX}-${var.RESOURCE_GROUP_NAME}-${var.SQL_SERVER_NAME}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  depends_on = [
    azurerm_resource_group.rg
  ]
}

#SQL DB
module "mssql_database" {
  source    = "./modules/mssql_database_module"
  name      = "${var.PREFIX}-${var.RESOURCE_GROUP_NAME}-${var.DB_NAME}"
  server_id = module.mssql_server.mssql_server_id
}

##################################################################################
### Storage

#Storage Account
module "storage_account" {
  source              = "./modules/storage_account_module"
  name                = "${var.RESOURCE_GROUP_NAME}${var.PREFIX}sa"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

}

#Storage container
module "storage_container" {
  source               = "./modules/storage_container_module"
  name                 = "images"
  storage_account_name = module.storage_account.storage_account_name
}

##################################################################################
### Management 

#KV
module "azurerm_key_vault" {
  source              = "./modules/azurerm_key_vault"
  name                = var.RESOURCE_GROUP_NAME == "specific-location" ? "${var.KV_NAME}-specific-location-${var.PREFIX}" : "${var.KV_NAME}-normal-${var.PREFIX}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#Policy for backend app
resource "azurerm_key_vault_access_policy" "kv_backend_app_access" {
  key_vault_id = module.azurerm_key_vault.azurerm_key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = module.app_service_backend.azurerm_app_identity_principal_id

  secret_permissions = [
    "Get", "List",
  ]
}

##################################################################################
### Secrets

module "azurerm_key_vault_secret_mssql_server_administrator_login" {
  source       = "./modules/azurerm_key_vault_secret"
  name         = "mssql-server-administrator-login"
  value        = module.mssql_server.mssql_server_administrator_login
  key_vault_id = module.azurerm_key_vault.azurerm_key_vault_id
}

module "azurerm_key_vault_secret_mssql_server_administrator_login_password" {
  source       = "./modules/azurerm_key_vault_secret"
  name         = "mssql-server-administrator-login-password"
  value        = module.mssql_server.mssql_server_administrator_login_password
  key_vault_id = module.azurerm_key_vault.azurerm_key_vault_id
}

module "azurerm_key_vault_secret_sql_connection_string_secret" {
  source       = "./modules/azurerm_key_vault_secret"
  name         = "SqlConnectionString"
  value        = "Server=tcp:${module.mssql_server.fully_qualified_domain_name},1433;Initial Catalog=${module.mssql_database.database_name};Persist Security Info=False;User ID=${module.mssql_server.mssql_server_administrator_login};Password=${module.mssql_server.mssql_server_administrator_login_password};MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  key_vault_id = module.azurerm_key_vault.azurerm_key_vault_id
}

module "azurerm_key_vault_secret_storage_account_connectionstring" {
  source       = "./modules/azurerm_key_vault_secret"
  name         = "ImageContainerConnectionString"
  value        = module.storage_account.storage_account_connectionstring
  key_vault_id = module.azurerm_key_vault.azurerm_key_vault_id
}

##################################################################################
### secrets needed for backend app

module "azurerm_key_vault_secret_AzureAd--Audience" {
  source       = "./modules/azurerm_key_vault_secret"
  name         = "DOMAIN"
  value        = var.DOMAIN
  key_vault_id = module.azurerm_key_vault.azurerm_key_vault_id
}

module "azurerm_key_vault_secret_AzureAd--ClientId" {
  source       = "./modules/azurerm_key_vault_secret"
  name         = "ClientId"
  value        = data.azurerm_client_config.current.client_id
  key_vault_id = module.azurerm_key_vault.azurerm_key_vault_id
}

module "azurerm_key_vault_secret_AzureAd--TenantId" {
  source       = "./modules/azurerm_key_vault_secret"
  name         = "TenantId"
  value        = data.azurerm_client_config.current.tenant_id
  key_vault_id = module.azurerm_key_vault.azurerm_key_vault_id
}
