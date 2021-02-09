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
