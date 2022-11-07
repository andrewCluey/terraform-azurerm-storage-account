/**
 * # terraform-azurerm-storage-account
 *
 * Creates a new Storage Account with option to create containers and Blob Private Endpoint.
 *
 * This module does not currently support implenmentation of Access Policies for tables, Containers, queues etc.
 * Please use RBAC instead.
 * 
 * Changes in this version:
 *   - Breaking changes from v2.x
 *   - Removed Private Endpoint resources. Use the separate private_endpoint module if you need a PE.
 *
 *
 * Future changes to include:
 *   - Update Azurerm provider to use 3.29.x, Additional attributes available.
 *   - Add options for choosing different file authentication methods (AD)
 *   - Options to change tier and protocol for shares.
 *   - Identity-based authentication (Active Directory) for Azure file shares
 *   - Add dynamic block for Table Access Policy
 *   
 */



# --------------------------------------------------------------
# Create Storage Account
# --------------------------------------------------------------
resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = var.sa_resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.repl_type
  is_hns_enabled           = var.datalake_v2
  tags                     = var.tags
  min_tls_version          = var.tls_ver
  #public_network_access_enabled = var.public_network_access_enabled   # requires later provider version.. Future release.

  #dynamic "azure_files_authentication" {
  #  for_each = local.set_az_file_auth == true ? [local.file_authentication_type] : []
  #  content {
  #    directory_type = "AADDS" # improvement to allow either AADDS or AD
  #  }
  #}
}

/* These local vars will be used with the azure_files_authentication block in a future release.

locals {
  set_az_file_auth         = var.storage_shares != [] ? true : false # Is var.storage_shares empty list or not?
  file_authentication_type = "AADDS"
}
*/


# --------------------------------------------------------------
# Create Blob Containers
# --------------------------------------------------------------

# Future improvement, allow other access types.
resource "azurerm_storage_container" "container" {
  for_each              = toset(var.blob_containers)
  name                  = each.key
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = "private"
  depends_on = [
    azurerm_storage_account.storage_account,
  ]
}


# --------------------------------------------------------------
# Create Storage Shares
# --------------------------------------------------------------

# Future improvements: 
#     - options to change tier, protocol etc.
#     - Identity-based authentication (Active Directory) for Azure file shares
resource "azurerm_storage_share" "share" {
  for_each             = toset(var.storage_shares)
  name                 = each.key
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 50
  access_tier          = "Hot"
  enabled_protocol     = "SMB"
}


# --------------------------------------------------------------
# Create Storage Tables
# --------------------------------------------------------------

resource "azurerm_storage_table" "table" {
  for_each             = toset(var.storage_tables)
  name                 = each.key
  storage_account_name = azurerm_storage_account.storage_account.name
}


# --------------------------------------------------------------
# Create Storage Queues
# --------------------------------------------------------------

resource "azurerm_storage_queue" "queue" {
  for_each             = toset(var.storage_queues)
  name                 = each.key
  storage_account_name = azurerm_storage_account.storage_account.name
}


# --------------------------------------------------------------
# Network rules
# --------------------------------------------------------------
resource "azurerm_storage_account_network_rules" "net_rules" {
  storage_account_id         = azurerm_storage_account.storage_account.id
  default_action             = var.default_action
  ip_rules                   = var.allowed_public_ip
  virtual_network_subnet_ids = var.allowed_subnet_ids
  bypass                     = var.bypass_services
}

