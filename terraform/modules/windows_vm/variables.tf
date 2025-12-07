variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "key_vault_id" {
  description = "The ID of the Key Vault to store VM passwords"
  type        = string
}

variable "resource_group_location" {
  default     = "northeurope"
  description = "Location of the resource group."
}

variable "prefix" {
  type        = string
  default     = "win-vm-iis"
  description = "Prefix of the resource name"
}

variable "vm_names" {
  description = "A list of VM names to create"
  type        = list(string)
  default     = ["vm1", "vm2", "vm3"] # List of VM names
}

variable "vm_size" {
  description = "The size of the Virtual Machine"
  type        = string
  default     = "Standard_D2s_v3"
}