
# Create a Public IP address
resource "azurerm_public_ip" "public_ip" {
  name                = "${var.prefix}-${random_string.suffix.result}-PIP"
  location            = var.location
  resource_group_name = var.virtualmachines_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a network interface
resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-${random_string.suffix.result}-NIC"
  location            = var.location
  resource_group_name = var.virtualmachines_rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.virtualmachines_subnet
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

#Associate NSG with the subnet
resource "azurerm_subnet_network_security_group_association" "subnet-nsg" {
  subnet_id                 = var.virtualmachines_subnet
  network_security_group_id = var.nsg_id
}

# resource "azurerm_network_interface_security_group_association" "nic_nsg" {
#   network_interface_id      = azurerm_network_interface.nic.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }


# Create a Windows virtual machine
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.location
  resource_group_name   = var.virtualmachines_rg.name
  size                  = var.vm_size
  computer_name         = var.vm_name
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic.id]
  tags                  = var.tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.disk_size_gb
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}


# Install IIS web server to the virtual machine
# resource "azurerm_virtual_machine_extension" "web_server_install" {
#   name                   = "install-web-server"
#   virtual_machine_id     = azurerm_windows_virtual_machine.vm.id
#   publisher              = "Microsoft.Compute"
#   type                   = "CustomScriptExtension"
#   type_handler_version   = "1.8"
#   auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#     {
#       "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
#     }
#   SETTINGS
# }

# Random pet for prefix
# resource "random_pet" "prefix" {
#   prefix = var.prefix
#   length = 1
# }

# Random suffix for unique resource names
resource "random_string" "suffix" {
  length  = 6
  upper   = false # no uppercase
  special = false # no special characters
  numeric = true  # include numbers
}