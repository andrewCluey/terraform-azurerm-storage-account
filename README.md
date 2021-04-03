# terraform-azurerm-storage-account
Terraform module to create an Azure Storage Account with a Private Endpoint.

## Example Use
```hcl
data "azurerm_subnet" "pe_default" {
  name                 = default_subnet
  virtual_network_name = default_vnet
  resource_group_name  = networkk_rg
}

locals {
  pe_subnet_id = data.azurerm_subnet.pe_default.id
}

resource "azurerm_resource_group" "test" {
  name     = "resources"
  location = "West Europe"
}

module "storage-account" {
  source  = "andrewCluey/storage-account/azurerm"
  version = "1.5.0"

  location                    = var.location
  sa_resource_group_name      = azurerm_resource_group.test.name
  storage_account_name        = "storageaccountname"
  pe_subnet_id                = local.pe_subnet_id
  resource_type               = ["blob"]
  private_dns_zone = [{
    id   = "/subscriptions/xxxxxxxxuuuuuuuuu/resourceGroups/dnszoneResourceGroup/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
    name = "privatelink.blob.core.windows.net"
}]
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
Private Endpoints are a really great way to ensure access to Azure Resources is only via private networks. This could be via an ExpressRoute link, or site-to-site VPN (On-Premise TO Azure). Key point is that this will change the default behaviour for the Resource being deployed, so that no acess is over the public Internet, instead via a private interface with a valid private IP address on the corporate network.

There are several external dependencies for Private Endpoints to work correctly, but they are well worth investing the time and effort to get working. Fortunately, this isn't as complex as you might think it is.

In short, the basic requirements are:

- Some form of Site-Site connection (VPN, ExpressRoute etc)
- Azure vNETs created with IP address spaces that are valid on the Corproate network, likely with peering enabled to make use of the site-to-site link (think Hub/Spoke layout). IMPORTANTLY - avoid overlapping IP addresses at all costs.
- DNS Forwarders. Probably the trickiest bit about the whole thing, however, if you understand DNS, then you should be fine. 

Whilst this isn't overly difficult to implement, it should be done with proper planning, design and change control. In a large corporate environment, the possibility of there being a random subnet, somewhere that hasn't been documented correctly is, sadly, all too common. You might 'assume' that subnet range 10.145.0.0/16 is available, but assuming anything makes an ASS out of U and ME.

### DNS Forwarding
This is perhaps the most complex bit, but only because there are so many moving parts required. At a high level, you need to create a new Private DNZ Zone in Azure, deploy at least one new Virtual Machine (preferably at least 2). If your on-premise DNS Servers are Windows, then deploy Windows VMs in Azure. These VMs will be DNS forwarding servers, so they don't need to be huge beasts, just enough to comfortably deal with DNS traffic.

The following document explains this in great detail, but the diagrams showing the end to end flow of different scenarios, are pretty brilliant and explain exactly how it works. In fact, I'd start by looking at these before reading the whole document. Particularly the diagram under ```On-premises workloads using a DNS forwarder``` section as this is most likely the integration required in an enterprise environment.


https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns

## Storage Account
To access a storage account in Azure you reference a provided FQDN. By default this will route over the Public Internet. For all sorts of reasons, many organisations do not want to access storage accounts in this way (or many other Azure resources for that matter).

This is where Private Endpoints come in.

