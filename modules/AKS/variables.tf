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
  default     = "/subscriptions/da9a301e-7a82-4e73-abb1-e28a503a0adf/resourceGroups/thesisRG/providers/Microsoft.Network/virtualNetworks/thesis-vnet/subnets/thesis-subnet"
}
