variable "StorageAccount_resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "thesis-storage-rg"
}

variable "StorageAccount_location" {
  description = "Azure region"
  type        = string
  default     = "West Europe"
}

variable "StorageAccount_storage_account_name" {
  description = "Name of the Storage Account (must be globally unique and between 3-24 characters)"
  type        = string
  default     = ""
}

variable "StorageAccount_account_tier" {
  description = "The performance tier of the storage account (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "StorageAccount_account_replication_type" {
  description = "The replication strategy for the storage account (LRS, GRS, RAGRS, ZRS)"
  type        = string
  default     = "LRS"
}

