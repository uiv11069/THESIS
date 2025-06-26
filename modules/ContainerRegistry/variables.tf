variable "resource_group_name" {
  description = "Name of the Resource Group for Container Registry"
  type        = string
  default     = "thesis-acr-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
  default     = "thesisacrregistry"
}

variable "acr_sku" {
  description = "SKU for the Azure Container Registry (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
}
