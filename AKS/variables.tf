variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "thesisRG"
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
  default     = "West Europe"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "thesis-aks"
}

variable "subnet_id" {
  description = "Subnet ID where AKS will be deployed"
  type        = string
  default     = "/subscriptions/42f0aa72-9941-46be-a162-e863bd1c1caf/resourceGroups/thesisRG/providers/Microsoft.Network/virtualNetworks/thesis-vnet/subnets/thesis-subnet"
}
