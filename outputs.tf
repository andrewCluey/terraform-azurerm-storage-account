output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

output "blobs" {
  description = "A list of all the blobs that have been created (if specified)."
  value       = [for k in azurerm_storage_container.blob : k.name]
}

output "id" {
  value = azurerm_storage_account.storage_account.id
}

output "private_endpoint_ip_address" {
  value = length(azurerm_private_endpoint.pe_blob) > 0 ? azurerm_private_endpoint.pe_blob[0].private_service_connection[0].private_ip_address : null
}

#output "primary_blob_endpoint" {
#  value = azurerm_storage_account.storage_account.primary_blob_endpoint
#}
