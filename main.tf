######################################################
# Creates a new Storage Account with Private Endpoints
######################################################

# ################################################
# DATA LOOKUPS
# Get data for resources already deployed.
# Takes inputs from user specified variables file.
# ################################################
provider "azurerm" {
  features {}
}
# Subnet where PE is to be created
data "azurerm_subnet" "pe_subnet" {
  name                 = var.pe_subnet_name
  virtual_network_name = var.pe_vnet_name
  resource_group_name  = var.pe_vnet_resource_group_name
}

# Resource Group where the Storage Account & corresponding Private Endpoint will be created
data "azurerm_resource_group" "storage_rg" {
  name = var.sa_resource_group_name
}

######################
# Create the Storage Account
######################
resource "azurerm_storage_account" "pe_storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = data.azurerm_resource_group.storage_rg.name
  location                 = data.azurerm_resource_group.storage_rg.location
  account_tier             = var.account_tier
  account_replication_type = var.repl_type
  is_hns_enabled           = var.datalake_v2
  tags                     = var.tags
}

###############################
# Creates a new Private Endpoint
###############################

resource "azurerm_private_endpoint" "pe" {
  name                = "${azurerm_storage_account.pe_storage_account.name}-pe"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.storage_rg.name
  subnet_id           = data.azurerm_subnet.pe_subnet.id

  private_service_connection {
    name                           = "${azurerm_storage_account.pe_storage_account.name}-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.pe_storage_account.id
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = var.private_blob_dns_zone_name
    private_dns_zone_ids = [var.private_blob_dns_zone_id]
  }
}
