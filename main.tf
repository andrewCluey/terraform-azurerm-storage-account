######################################################
# Creates a new Storage Account with Private Endpoints
######################################################

############################
# Create the Storage Account
############################
resource "azurerm_storage_account" "pe_storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = var.sa_resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.repl_type
  is_hns_enabled           = var.datalake_v2
  tags                     = var.tags
  min_tls_version          = var.tls_ver
}

################################
# Creates a new Private Endpoint
################################

resource "azurerm_private_endpoint" "pe" {
  name                = "${azurerm_storage_account.pe_storage_account.name}-pe"
  location            = var.location
  resource_group_name = var.sa_resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${azurerm_storage_account.pe_storage_account.name}-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.pe_storage_account.id
    subresource_names              = var.resource_type
  }

  private_dns_zone_group {
    name                 = var.private_dns_zone_name
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
