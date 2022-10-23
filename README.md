<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-storage-account

Creates a new Storage Account with option to create containers and Blob Private Endpoint.
Future changes include:
  - Network ACL options.
  - Option to create File shares, Queues and Tables

## Example - default
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.10.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg_testpe" {
  name     = "rg-test-sa"
  location = "uksouth"
}

# Creates Storage Account in default location (WestEurope).
module "storage_account" {
  source  = "andrewCluey/storage-account/azurerm"
  version = "2.0.0"

  storage_account_name    = "sasimple83e32q"
  sa_resource_group_name  = azurerm_resource_group.rg_testpe.name
  blob_containers         = local.blob_containers_tocreate
}
```

## Example - with PE

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.10.0"
    }
  }
}

provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "rg_testpe" {
  name     = "rg-test-sa"
  location = "uksouth"
}
resource "azurerm_virtual_network" "vn_testpe" {
  name                = "testpe-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_testpe.location
  resource_group_name = azurerm_resource_group.rg_testpe.name
}

resource "azurerm_subnet" "sn_testpe" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.rg_testpe.name
  virtual_network_name = azurerm_virtual_network.vn_testpe.name
  address_prefixes     = ["10.0.1.0/24"]
}

# create private DNS zone
resource "azurerm_private_dns_zone" "dns_testpe" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg_testpe.name
}

# define local variables to use as inputs into the module.
locals {
  blob_containers_tocreate = ["z-blob", "default", "u2-blob", "autotest", "f-blob", "x-blob" ]
}

module "storage_account" {
  source  = "andrewCluey/storage-account/azurerm"
  version = "2.0.0"

  storage_account_name    = "sasimple83e32q"
  location                = azurerm_resource_group.rg_testpe.location
  sa_resource_group_name  = azurerm_resource_group.rg_testpe.name
  blob_containers         = local.blob_containers_tocreate
  deploy_private_endpoint = true
  pe_subnet_id            = azurerm_subnet.sn_testpe.id
  private_dns_zone        = {
    name = azurerm_private_dns_zone.dns_testpe.name
    id   = azurerm_private_dns_zone.dns_testpe.id
  }
}

output "blobs" {
  description = "All blob containers created."
  value       = sort(module.storage_account.blobs)
}

output "private_endpoint_ip_address" {
  description = "The private IP Address assigned to the Private Endpoint."
  value       = module.storage_account.private_endpoint_ip_address
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | The Storage Tier for the new Account. Options are 'Standard' or 'Premium' | `string` | `"Standard"` | no |
| <a name="input_blob_containers"></a> [blob\_containers](#input\_blob\_containers) | List all the blob containers to create. | `list(any)` | `[]` | no |
| <a name="input_datalake_v2"></a> [datalake\_v2](#input\_datalake\_v2) | Enabled Hierarchical name space for Data Lake Storage gen 2 | `bool` | `false` | no |
| <a name="input_deploy_private_endpoint"></a> [deploy\_private\_endpoint](#input\_deploy\_private\_endpoint) | Deploy a private endopoint with the storage accoubnt. True/False. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region of where the Storage Account & Private Endpoint are to be created. | `string` | `"westeurope"` | no |
| <a name="input_pe_subnet_id"></a> [pe\_subnet\_id](#input\_pe\_subnet\_id) | The ID of the subnet where the Private Endpoint will be created. | `string` | `""` | no |
| <a name="input_private_dns_zone"></a> [private\_dns\_zone](#input\_private\_dns\_zone) | The name and ID of the privatelink DNS zone in Azure to register the Private Endpoint resource type.<br>  Requires an input map object. EXAMPLE:<br>  private-dns\_zone = {<br>    name = "privatelink.blob.azure.windows.net"<br>    id   = "hyoiuhyou-8y98/uhi"<br>  } | `any` | `{}` | no |
| <a name="input_repl_type"></a> [repl\_type](#input\_repl\_type) | The replication type required for the new Storage Account. Options are LRS; GRS; RAGRS; ZRS | `string` | `"GRS"` | no |
| <a name="input_sa_resource_group_name"></a> [sa\_resource\_group\_name](#input\_sa\_resource\_group\_name) | The name of a Resource Group to deploy the new Storage Account into. | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name to assign to the new Storage Account. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | tags to apply to the new resources | `map(string)` | `null` | no |
| <a name="input_tls_ver"></a> [tls\_ver](#input\_tls\_ver) | Minimum overison of TLS that must be used to connect to the storage account | `string` | `"TLS1_2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_blobs"></a> [blobs](#output\_blobs) | A list of all the blobs that have been created (if specified). |
| <a name="output_id"></a> [id](#output\_id) | The ID of the newly created Storage Account. |
| <a name="output_private_endpoint_ip_address"></a> [private\_endpoint\_ip\_address](#output\_private\_endpoint\_ip\_address) | The IP Address of the Private Endpoint. |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the new Storage Account. |
| <a name="output_storage_name"></a> [storage\_name](#output\_storage\_name) | The primary blob endpoint. |
<!-- END_TF_DOCS -->