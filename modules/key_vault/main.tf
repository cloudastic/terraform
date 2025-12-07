data "azurerm_client_config" "current" {}

locals {
  # Only provide Service Principal IDs that require Key Vault Admin access  
  kv_admins = [
    "0a7f987c-d89e-4901-b80d-f7d60069adfc", # Service Principal ID that requires access to Create Secrets in Key Vault
  ]
  kv_users = [
    "525eee18-2436-471a-b517-6cd487d07bb0", "0a7f987c-d89e-4901-b80d-f7d60069adfc" # User ID that requires access to Create Secrets in Key Vault
  ]
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_key_vault" "this" {
  name                       = "${var.name}-${random_string.suffix.result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  rbac_authorization_enabled = true
  tenant_id                  = var.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 7
  purge_protection_enabled   = true
  tags                       = var.tags
}


