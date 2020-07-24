output "storage_account_name" {
  value = azurerm_storage_account.pe_storage_account.name
}

output "private_endpoint_ip_address" {
  value = azurerm_private_endpoint.pe.private_service_connection[0].private_ip_address
}
