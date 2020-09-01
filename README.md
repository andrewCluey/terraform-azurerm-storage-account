# terraform-azurerm-storage-account
Terraform module to create a storage account with a Private Endpoint

## Example Usage
```hcl
resource "azurerm_resource_group" "test" {
  name     = "resources"
  location = "West Europe"
}

module "storageaccount" {
  source  = "gitrepo/storageaccount/azurerm"
  version = "0.0.8"

  sa_resource_group_name      = azurerm_resource_group.test.name
  storage_account_name        = "sstorageaccountname"
  pe_vnet_resource_group_name = "privateendpoint-vnet-resourcegroup"
  pe_subnet_name              = "privateendpoint-subnet-name"
  pe_vnet_name                = "privateendpoint-vnet-name"
  private_blob_dns_zone_id    = "/subscriptions/xxxxxxxxuuuuuuuuu/resourceGroups/dnszoneResourceGroup/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  private_blob_dns_zone_name  = "privatelink.blob.core.windows.net"
  tags = { Terraform = true,
    environment = "DEV"
  }
}
```

## Arguments

## Create a Storage Account with a Private Endpoint in Azure

This Terraform module deploys a new Storage Account in Azure.

The module will create a single blob container with a private endpoint to provide more control over network access to the blob containers.
