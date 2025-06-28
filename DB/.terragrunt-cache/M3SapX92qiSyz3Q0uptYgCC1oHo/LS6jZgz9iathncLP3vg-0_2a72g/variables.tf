variable "DB_resource_group_name" {
  description = "Name of the Resource Group"
  type        = string
  default     = "thesis-db-rg"
}

variable "DB_location" {
  description = "Azure region"
  type        = string
  default     = "Australia East"
}

variable "DB_server_name" {
  description = "SQL Server Name (must be globally unique)"
  type        = string
  default     = "thesis-sql-server"
}

variable "DB_admin_username" {
  description = "Administrator username for the SQL server"
  type        = string
  default     = "sqladminuser"
}

variable "DB_admin_password" {
  description = "Administrator password for the SQL server"
  type        = string
  sensitive   = true
}

variable "DB_database_name" {
  description = "Name of the SQL Database"
  type        = string
  default     = "thesis_sqldb"
}

variable "DB_sku_name" {
  description = "SKU name for the SQL database (e.g., S0, Basic, etc.)"
  type        = string
  default     = "Basic"
}
