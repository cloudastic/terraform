output "virtual_machine_names" {
  description = "Name of the Azure Virtual Machine"
  # Use a for expression to loop through each VM instance created by for_each
  value = {
    for k, vm in azurerm_windows_virtual_machine.main : k => vm.name
  }
}

output "public_ip_address" {
  description = "The public IP addresses of all deployed VMs."
  # Use a for expression to loop through each VM instance created by for_each
  value = {
    for k, vm in azurerm_windows_virtual_machine.main : k => vm.public_ip_address
  }
}

output "vm_private_ip" {
  description = "The Private IP Address of the Virtual Machine"
  value = {
    for k, vm in azurerm_network_interface.terraform_nic : k => vm.private_ip_address
  }
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}


  