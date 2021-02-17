output "storage_account_name" {
  value = azurerm_storage_account.pe_storage_account.name
}

output "primary_blob_endpoint" {
  value = azurerm_storage_account.pe_storage_account.primary_blob_endpoint
}

output "id" {
  value = azurerm_storage_account.pe_storage_account.id
}

output "private_endpoint_ip_address" {
  value = azurerm_private_endpoint.pe_blob.private_service_connection[0].private_ip_address
}

output "default_blob_endpoint" {
  description = "The endpoint URL for the default blob storage account in the primary location"
  value       = azurerm_storage_account.pe_storage_account.primary_blob_endpoint
}