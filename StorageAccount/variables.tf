variable "resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "thesis-storage-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "storage_account_name" {
  description = "Name of the Storage Account (must be globally unique and between 3-24 characters)"
  type        = string
  default     = "licentastorageaccount"
}

variable "account_tier" {
  description = "The performance tier of the storage account (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "The replication strategy for the storage account (LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "LRS"
}

variable "tags" {
  description = "A map of tags to associate with the resource"
  type        = map(string)
  default     = {
    environment = "dev"
  }
}
