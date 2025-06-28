variable "ContainerApp_resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "thesis-container-rg"
}

variable "ContainerApp_location" {
  description = "Azure region for the Container App"
  type        = string
  default     = "West Europe"
}

variable "ContainerApp_app_name" {
  description = "Name of the Container App"
  type        = string
  default     = ""
}
