#############################################################################
# VARIABLES
#############################################################################

########################## Backend
variable "BACKEND-RGNAME" {
  type = string
}

variable "BACKEND-STACCOUNT" {
  type = string
}

variable "BACKEND-CNTNAME" {
  type = string
}

variable "BACKEND-KEY" {
  type = string
}

########################## Basic
variable "RESOURCE_GROUP_NAME" {
  type = string
}

variable "ENV" {
  type = string
}

variable "LOCATION" {
  type = string
}

variable "PREFIX" {
  type = string
}

########################## App Plan
variable "APP_SERVICE_PLAN_NAME" {
  type = string
}

variable "SKU_TIER" {
  type = string
}

variable "SKU_SIZE" {
  type = string
}

########################## App Service
variable "APP_SERVICE_BACKEND_NAME" {
  type = string
}

variable "APP_SERVICE_FRONTEND_NAME" {
  type = string
}

########################## SQL Server
variable "SQL_SERVER_NAME" {
  type = string
}

########################## DB
variable "DB_NAME" {
  type = string
}

########################## KV
variable "KV_NAME" {
  type = string
}

########################## Secrets

variable "DOMAIN" {
  type = string
}
