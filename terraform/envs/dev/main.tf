locals {
  # Only provide Service Principal IDs that require Key Vault Admin access  
  kv_admins = [
    "525eee18-2436-471a-b517-6cd487d07bb0", # Service Principal ID that requires access to Create Secrets in Key Vault
  ]
}

data "azurerm_client_config" "current" {}


module "resource_group" {
  source   = "../../modules/resource_group"
  name     = "elekta-devops-test"
  location = "northeurope"
  tags     = { environment = "dev" }
}

module "key_vault" {
  source              = "../../modules/key_vault"
  name                = "devops-kv"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = { environment = "dev" }
}

resource "azurerm_role_assignment" "sp_kv_secrets_officer" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = "525eee18-2436-471a-b517-6cd487d07bb0" # SP Object ID
  principal_type       = "ServicePrincipal"
}

# creates VNet, subnet, NSG with RDP rule
module "network" {
  source              = "../../modules/virtual_network"
  prefix              = var.prefix
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_name           = "DEV-VNET"
  address_space       = ["10.0.0.0/16"]
  security_rules      = var.security_rules_enable_rdp

  subnets = {
    dev_snet_1 = { address_prefixes = ["10.0.1.0/24"] } # Create new Subnet for each VM modules. 
    dev_snet_2 = { address_prefixes = ["10.0.2.0/24"] } # Create new Subnet for each VM modules. 
  }
}

# Create a random password for each VM
resource "random_password" "vm_password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}



####################################################

# Random Password to be created for vm-test-1 stored in Key Vault
resource "azurerm_key_vault_secret" "vm-test-1-password" {
  name         = "vm-password-vm-test-1"
  value        = random_password.vm_password.result
  key_vault_id = module.key_vault.id
}

# Create Virtual Machine : vm-test-1
module "vm-test-1-module" {
  source                 = "../../modules/windows_vms"
  prefix                 = "DEV"
  vm_name                = "vm-test-1"
  location               = "northeurope"
  virtualmachines_rg     = module.resource_group
  virtualmachines_subnet = module.network.subnet_ids["dev_snet_1"]
  nsg_id                 = module.network.nsg_id

  vm_size        = "Standard_D2s_v3"
  disk_size_gb   = 200
  admin_username = "Elekta"
  admin_password = azurerm_key_vault_secret.vm-test-1-password.value # Use the password from Key Vault

  tags = {
    purpose     = "dev-vm"
    environment = "development"
    managed_by  = "terraform"
  }
}

####################################################

# Random Password to be created for vm-test-1 stored in Key Vault
resource "azurerm_key_vault_secret" "vm-test-2-password" { # UPDATE HERE : Change the resource name to be in-line with the VM created
  name         = "vm-password-vm-test-2"                   # UPDATE HERE : Change the secret name to be in-line with the VM created
  value        = random_password.vm_password.result
  key_vault_id = module.key_vault.id
}

# Create Virtual Machine : vm-test-2
module "vm-test-2-module" { # UPDATE HERE : Change the module name to be in-line with the VM created
  source                 = "../../modules/windows_vms"
  prefix                 = "DEV"
  vm_name                = "vm-test-2" # UPDATE HERE : Change the vm_name to vm-test-2
  location               = "northeurope"
  virtualmachines_rg     = module.resource_group
  virtualmachines_subnet = module.network.subnet_ids["dev_snet_2"] # UPDATE HERE : Create a new subnet for each VM and associate the same here
  nsg_id                 = module.network.nsg_id
  vm_size                = "Standard_D2s_v3"
  disk_size_gb           = 200
  admin_username         = "Elekta"
  admin_password         = azurerm_key_vault_secret.vm-test-2-password.value # UPDATE HERE : Refer to the appropriate secret name that was created.

  tags = {
    purpose     = "dev-vm"
    environment = "development"
    managed_by  = "terraform"
  }
}