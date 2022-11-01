/**
 * # terraform-azurerm-storage-account
 *
 * Creates a new Storage Account with option to create containers and Blob Private Endpoint.
 *
 * Changes in this version:
 *   - Breaking changes from v2.x
 *   - Removed Private Endpoint resources. Use the separate private_endpoint module if you need a PE.
 *
 *
 * Future changes include:
 *   - Network ACL options
 *   - Option to create Queues and Tables
 *   - add additional options for choosing different file authentication methods (AD)
 *   - Options to change tier and protocol for shares.
 */


locals {
  set_az_file_auth         = var.storage_shares != [] ? true : false # Is var.storage_shares empty list or not?
  file_authentication_type = "AADDS"
}


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

  #dynamic "azure_files_authentication" {
  #  for_each = local.set_az_file_auth == true ? [local.file_authentication_type] : []
  #  content {
  #    directory_type = "AADDS" # improvement to allow either AADDS or AD
  #  }
  #}
}


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

# Future improvement, options to change tier, protocol & ACL.
resource "azurerm_storage_share" "share" {
  for_each             = toset(var.storage_shares)
  name                 = each.key
  storage_account_name = azurerm_storage_account.storage_account.name
  quota                = 50
  access_tier          = "Hot"
  enabled_protocol     = "SMB"
  /*
  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
      start       = "2019-07-02T09:38:21.0000000Z"
      expiry      = "2019-07-02T10:38:21.0000000Z"
    }
  }
  */
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

