variable "VirtualNetwork_resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "VirtualNW_RG" # Default resource group name
}

variable "VirtualNetwork_location" {
  description = "Azure region for the resources"
  type        = string
  default     = "West Europe" # Default location
}

variable "VirtualNetwork_vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = ""
}

variable "VirtualNetwork_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "VirtualNetwork_subnet_name" {
  description = "Name of the Subnet"
  type        = string
  default     = ""
}

variable "VirtualNetwork_subnet_address_prefixes" {
  description = "Address prefixes for the Subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "VirtualNetwork_environment" {
  description = "Environment tag (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}
