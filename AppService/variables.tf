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
  default     = "/subscriptions/42f0aa72-9941-46be-a162-e863bd1c1caf/resourceGroups/thesisRG/providers/Microsoft.Network/virtualNetworks/thesis-vnet/subnets/thesis-appservice-subnet"
}

