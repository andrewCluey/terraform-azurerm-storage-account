######################################################
# Creates a new Storage Account with Private Endpoints
######################################################
locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  
  tags = merge(var.tags, local.module_tag)
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

############################
# Create the Storage Account
############################
resource "azurerm_storage_account" "pe_storage_account" {
  name                      = var.storage_account_name
  resource_group_name       = var.sa_resource_group_name
  location                  = lookup(var.storage_account, "location", "uksouth")
  #name                      = lookup(var.storage_account, "name", "sa${random_sting.suffix.result}")
  account_tier              = lookup(var.storage_account, "account_tier", "Standard")
  account_replication_type  = lookup(var.storage_account, "account_replication_type", "LRS")
  is_hns_enabled            = lookup(var.storage_account, "is_hns_enabled", false)
  min_tls_version           = lookup(var.storage_account, "min_tls_version", "TLS1_2")
  account_kind              = lookup(var.storage_account, "account_kind", "StorageV2")
  access_tier               = lookup(var.storage_account, "access_tier", "Hot")
  allow_blob_public_access  = lookup(var.storage_account, "allow_blob_public_access", false)
  tags                      = local.tags
}



resource "azurerm_storage_container" "default_blob" {
  # add count, default of '1', so deploying a blob container can be disabled if preferred. 
  name                  = var.default_container_name
  storage_account_name  = azurerm_storage_account.pe_storage_account.name
  container_access_type = "private"
}

###############################################################
# Creates a new Private Endpoint for the default blob container
###############################################################

resource "azurerm_private_endpoint" "pe_blob" {
  name                = "${var.default_container_name}-pe"
  location            = var.location
  resource_group_name = var.sa_resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-pe-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.pe_storage_account.id
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = var.private_dns_zone.name
    private_dns_zone_ids = [var.private_dns_zone.id]
  }
}

### 
# Network security
###
