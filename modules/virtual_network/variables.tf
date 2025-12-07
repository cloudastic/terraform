variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "prefix" {
  type        = string
  description = "Prefix for NSG"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "vnet_name" {
  type        = string
  description = "Name of the Virtual Network"
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used by the Virtual Network."
}

variable "subnets" {
  type = map(object({
    address_prefixes = list(string)
  }))
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "security_rules" {
  type = map(any)
  # default = {
  #   rdp = {
  #     name                       = "RDP-3389"
  #     priority                   = 300
  #     direction                  = "Inbound"
  #     access                     = "Allow"
  #     protocol                   = "Tcp"
  #     source_port_range          = "*"
  #     destination_port_ranges    = ["3389"]
  #     source_address_prefix      = "*"
  #     destination_address_prefix = "*"
  #   }
  # }
}