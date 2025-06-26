variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "thesis-container-rg"
}

variable "location" {
  description = "Azure region for the Container App"
  type        = string
  default     = "West Europe"
}

variable "app_name" {
  description = "Name of the Container App"
  type        = string
  default     = "minimal-container-app"
}
