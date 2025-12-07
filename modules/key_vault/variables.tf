variable "name" {
  type        = string
  description = "Base name of the Key Vault (random suffix will be added)"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "northeurope"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "tenant_id" {
  type        = string
  description = "Azure tenant ID"
}

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "tags" {
  type    = map(string)
  default = {}
}