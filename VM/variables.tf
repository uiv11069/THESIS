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
  default     = "/subscriptions/da9a301e-7a82-4e73-abb1-e28a503a0adf/resourceGroups/thesisRG/providers/Microsoft.Network/virtualNetworks/thesis-vnet/subnets/thesis-subnet"
}
