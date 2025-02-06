variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "thesisRG" # Must match the existing Resource Group
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "subnet_id" {
  description = "ID of the subnet in the Virtual Network"
  type        = string
  default     = "/subscriptions/42f0aa72-9941-46be-a162-e863bd1c1caf/resourceGroups/thesisRG/providers/Microsoft.Network/virtualNetworks/thesis-vnet/subnets/thesis-subnet"
}
