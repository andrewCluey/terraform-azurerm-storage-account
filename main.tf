######################################################
# Creates a new Storage Account with Private Endpoints
######################################################

############################
# Create the Storage Account
############################
resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = var.sa_resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.repl_type
  is_hns_enabled           = var.datalake_v2
  tags                     = var.tags
  min_tls_version          = var.tls_ver
}


# Future improvement, allow other access types.
resource "azurerm_storage_container" "blob" {
  for_each              = toset(var.blob_containers)
  name                  = each.value
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
}

###############################################################
# Creates a new Private Endpoint for the default blob container
###############################################################

resource "azurerm_private_endpoint" "pe_blob" {
  count               = var.deploy_private_endpoint == true ? 1 : 0 # IF var.deploy_private_endpoint IS equal to TRUE, then deploy Private Endpoint.
  name                = "${var.storage_account_name}-pe"
  location            = var.location
  resource_group_name = var.sa_resource_group_name
  subnet_id           = var.pe_subnet_id

  private_service_connection {
    name                           = "${var.storage_account_name}-pe-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_storage_account.storage_account.id
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
