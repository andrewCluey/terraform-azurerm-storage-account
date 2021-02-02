# terraform-azurerm-storage-account
Terraform module to create a storage account with a Private Endpoint.

## Example Usage
```hcl
resource "azurerm_resource_group" "test" {
  name     = "resources"
  location = "West Europe"
}

module "storage-account" {
  source  = "andrewCluey/storage-account/azurerm"
  version = "1.4.0"

  location                    = var.location
  sa_resource_group_name      = azurerm_resource_group.test.name
  storage_account_name        = "storageaccountname"
  pe_vnet_resource_group_name = "privateendpoint-vnet-resourcegroup"
  pe_subnet_name              = "privateendpoint-subnet-name"
  pe_vnet_name                = "privateendpoint-vnet-name"
  resource_type               = ["blob"]
  private_blob_dns_zone_id    = "/subscriptions/xxxxxxxxuuuuuuuuu/resourceGroups/dnszoneResourceGroup/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  private_blob_dns_zone_name  = "privatelink.blob.core.windows.net"
  repl_type                   = "LRS"
  tls_ver                     = "TLS1_2"
  
  tags = { Terraform = true,
    environment = "DEV"
  }
}
 

```

## Required Arguments

| Name | Type | Required | Description |
| --- | --- | --- | --- |
| `sa_resource_group_name` | `string` | true | The name of the resource group where the new Storage Account Will be created. |
| `storage_account_name` | `string` | true | The name of the Storage Account. |
| `pe_vnet_resource_group_name` | `string` | true | The name of the resource group where the vNET for the Private Endpoint resides. |
| `pe_subnet_name` | `string` | true | The name of the Subnet where the Private Endpoint will be created. |
| `private_blob_dns_zone_id` | `string` | true | The ID of the blob DNS zone for the private endpoitn registration. |
| `private_blob_dns_zone_name` | `string` | true | The name of the DNS zone. |
| `tags` | `map` | false | A map of tags to apply to the new storage account and Private endpoint. EG - {Environment = "DEV", CreatedBy = "AC", Terraform = true} |
