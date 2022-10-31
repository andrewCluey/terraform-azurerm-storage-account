output "storage_account_name" {
  description = "The name of the new Storage Account."
  value       = azurerm_storage_account.storage_account.name
}

output "containers" {
  description = "A list of all the blob containers that have been created (if specified)."
  value       = [for k in azurerm_storage_container.container : k.name]
}

output "shares" {
  description = "A list of all the blobs that have been created (if specified)."
  value       = [for k in azurerm_storage_share.share : k.name]
}

output "id" {
  description = "The ID of the newly created Storage Account."
  value       = azurerm_storage_account.storage_account.id
}


# change to use for expression...
#output "private_endpoint_ip_address" {
#  description = "The IP Address of the Private Endpoint."
#  value       = length(azurerm_private_endpoint.pe) > 0 ? azurerm_private_endpoint.pe[0].private_service_connection[0].private_ip_address : null
#}

output "storage_name" {
  description = "The primary blob endpoint."
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
}

#output "primary_blob_endpoint" {
#  value = azurerm_storage_account.storage_account.primary_blob_endpoint
#}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location."
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
}
