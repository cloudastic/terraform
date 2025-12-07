variable "vm-name" {
  default = "vm-test-1"
  type    = string
}

variable "vm_size" {
  description = "The size of the Virtual Machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "prefix" {
  description = "Prefix for the resource to be created. (NSG)"
  type        = string
  default     = "PROD"
}

variable "vnet" {
  description = "Virtual Network where all the resources will be created"
  default     = "prod_vnet_1"
}

variable "security_rules_enable_rdp" {
  type = map(any)
  default = {
    rdp = {
      name                       = "RDP-3389"
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = ["3389"]
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }
}
