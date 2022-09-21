#############################################################################
# VARIABLES
#############################################################################

variable "app_service_web_name" {
  type = string
}


variable "location" {
  type = string
}


variable "resource_group_name" {
  type = string
}


variable "app_service_plan_id" {
  type = string
}

variable "CorsOrigin" {
  type    = string
  default = null
}


variable "SystemAssignedIdentity" {
  type    = bool
  default = false
}

