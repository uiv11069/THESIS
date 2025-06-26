variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "thesisRG" # Default resource group name
}

variable "location" {
  description = "Azure region for the resources"
  type        = string
  default     = "West Europe" # Default location
}

variable "vnet_name" {
  description = "Name of the Virtual Network"
  type        = string
  default     = "thesis-vnet"
}

variable "address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Name of the Subnet"
  type        = string
  default     = "thesis-subnet"
}

variable "subnet_address_prefixes" {
  description = "Address prefixes for the Subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "environment" {
  description = "Environment tag (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}
