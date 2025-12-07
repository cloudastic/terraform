output "vnet_id" {
  description = "The ID of the Virtual Network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "IDs of the created subnets"
  value       = { for k, v in azurerm_subnet.subnets : k => v.id }
}

output "nsg_id" {
  description = "ID of the created NSG"
  value       = azurerm_network_security_group.nsg.id
}
