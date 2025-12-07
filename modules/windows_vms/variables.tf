variable "location" {
  description = "The location/region where the resources will be created."
  default     = "northeurope"
}

variable "virtualmachines_rg" {
  description = "Resource group for VirtualMachines"
}

variable "virtualmachines_subnet" {
  description = "Subnet for VirtualMachines"
}

variable "nsg_id" {
  description = "Network Security Group ID"
}


# variable "security_rules" {
#   type = map
#   # default = {
#   #   rdp = {
#   #     name                       = "RDP-3389"
#   #     priority                   = 300
#   #     direction                  = "Inbound"
#   #     access                     = "Allow"
#   #     protocol                   = "Tcp"
#   #     source_port_range          = "*"
#   #     destination_port_ranges    = ["3389"]
#   #     source_address_prefix      = "*"
#   #     destination_address_prefix = "*"
#   #   }
#   # }
# }

variable "prefix" {
  description = "Prefix for the resource to be created."
}

variable "vm_name" {
  description = "Computer name for the created VM, must be less than 15 characters"
}

variable "vm_size" {
  description = "The size of the Virtual Machine"
  type        = string
  # default     = "Standard_D2s_v3"
}

variable "os_disk_type" {
  description = "OS disk type for the Windows VMS"
  default     = "Standard_LRS"
}

variable "disk_size_gb" {
  # default = 200
}

variable "tags" {
}

variable "admin_username" {
  type        = string
  description = "Administrator user name for virtual machine"
}

variable "admin_password" {
  type        = string
  description = "Password must meet Azure complexity requirements"
}

