# terraform-azurerm-storage-account
Terraform module to create a storage account with a Private Endpoint.

## Example Usage
```hcl
locals {
  pe_subnet_id = data.azurerm_subnet.pe_default.id
}

data "azurerm_subnet" "pe_default" {
  name                 = default_subnet
  virtual_network_name = default_vnet
  resource_group_name  = networkk_rg
}


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
  pe_subnet_id                = loca.pe_subnet_id
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


## Private Endpoints
Private Endpoints are a really great way to ensure access to Azure Resources is only via private networks. This could be via an ExpressRoute link, or site-to-site VPN (On-Premise TO Azure). Key point is that this will change the default behaviour for the Resource being deployed, so that no longe ris access over the pUblic Internetm but via a Private Interface, with a valid private IP address on your corportae network.

Obviously, there are several dependencies for private Endpoints to work correctly, but they are well worth investing the time and effort to get working. Fortunately, this isn't as complex as the Microsoft documentation makes you think it is.

In short, the basic requirements are:

- Some form of Site-Site connection (VPN, ExpressRout etc)
- Azure vNETs created with IP address spaces that are valid on the Corproate network. Avoid overlapping addressing at all costs.
- DNS Forwarders. Probably the trickiest bit about the whole thing, however, if you understand DNS, then you should be fine. 

### DNS Forwarding
This is perhaps the most complex bit, but only because there are so many moving parts required. At a high level, you need to create a new Private DNZ Zone in Azure, deploy some new servers in Azure (these will be DNS forwarding servers). Then, you need to create conditional forwarders on your 'on-premise' DNS servers for the various Azure resources that will have Private Endpoints, and conditional forwarders on your new Azure based DNS servers too.



