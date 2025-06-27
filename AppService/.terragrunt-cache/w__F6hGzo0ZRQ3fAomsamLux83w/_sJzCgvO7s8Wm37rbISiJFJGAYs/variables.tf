variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "thesisRG"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "app_name" {
  description = "Name of the App Service"
  type        = string
  default     = "thesis-appservice"
}

variable "subnet_id" {
  description = "ID of the App Service Subnet in the Virtual Network"
  type        = string
  default     = "/subscriptions/da9a301e-7a82-4e73-abb1-e28a503a0adf/resourceGroups/thesisRG/providers/Microsoft.Network/virtualNetworks/thesis-vnet/subnets/thesis-appservice-subnet"
}

