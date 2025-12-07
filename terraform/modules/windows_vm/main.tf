


# Create a random password for each VM
resource "random_password" "vm_password" {
  for_each    = toset(var.vm_names) # VM names (to generate a password per VM)
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

# Store the generated password in the existing Key Vault as a secret
resource "azurerm_key_vault_secret" "vm_password_secret" {
  for_each     = random_password.vm_password
  name         = "vm-password-${each.key}"
  value        = each.value.result
  key_vault_id = var.key_vault_id
}

# Create virtual network
resource "azurerm_virtual_network" "terraform_network" {
  name                = "${random_pet.prefix.id}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
}

# Create subnet
resource "azurerm_subnet" "terraform_subnet" {
  name                 = "${random_pet.prefix.id}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.terraform_network.name
  address_prefixes     = ["10.0.1.0/24"]
}



# Create public IPs
resource "azurerm_public_ip" "terraform_public_ip" {
  for_each            = toset(var.vm_names)
  name                = "${each.key}-pip"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create Network Security Group and rules
resource "azurerm_network_security_group" "terraform_nsg" {
  name                = "${random_pet.prefix.id}-nsg"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "Allow_RDP_access"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow_HTTP_access"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "terraform_nic" {
  for_each = toset(var.vm_names)

  name                = "${each.key}-${random_pet.prefix.id}-nic"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.terraform_public_ip[each.key].id
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nwsg_association" {
  for_each                  = azurerm_network_interface.terraform_nic
  network_interface_id      = each.value.id
  network_security_group_id = azurerm_network_security_group.terraform_nsg.id
}

# Enable it for Production use
# Create storage account for boot diagnostics
# resource "azurerm_storage_account" "storage_account" {
#   name                     = "diag${random_id.random_id.hex}"
#   location                 = var.resource_group_location
#   resource_group_name      = var.resource_group_name
#   account_tier             = "Standard"
#   account_replication_type = "LRS"
# }

# Create virtual machine
resource "azurerm_windows_virtual_machine" "main" {
  for_each              = toset(var.vm_names) # VM names (to create multiple VMs)
  name                  = each.key
  admin_username        = "Elekta"
  admin_password        = azurerm_key_vault_secret.vm_password_secret[each.key].value # Use the password from Key Vault
  location              = var.resource_group_location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.terraform_nic[each.key].id]
  size                  = var.vm_size # "Standard_D2s_v3" # Least expensive VM (for demo)

  os_disk {
    name                 = "myOsDisk-${each.key}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  # Configuring spot instances for cost savings (Only for Dev/Test)
  #   priority = "Spot"
  #   max_bid_price = -1 # Enable spot instance with no max price
  #   eviction_policy = "Deallocate"
}

# Install IIS web server to the virtual machine
resource "azurerm_virtual_machine_extension" "web_server_install" {
  for_each                   = toset(var.vm_names)
  name                       = "install-${each.key}"
  virtual_machine_id         = azurerm_windows_virtual_machine.main[each.key].id
  publisher                  = "Microsoft.Compute"
  type                       = "CustomScriptExtension"
  type_handler_version       = "1.8"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted Install-WindowsFeature -Name Web-Server -IncludeAllSubFeature -IncludeManagementTools"
    }
  SETTINGS
}

# Random pet for prefix
resource "random_pet" "prefix" {
  prefix = var.prefix
  length = 1
}