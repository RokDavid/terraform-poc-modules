#############################################################################
# VARIABLES
#############################################################################

variable "name" {
  type = string
}

variable "server_id" {
  type = string
}

variable "sku" {
  type    = string
  default = "S0"
}
