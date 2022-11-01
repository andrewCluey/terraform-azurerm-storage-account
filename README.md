<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-storage-account

Creates a new Storage Account with option to create containers and Blob Private Endpoint.

This module does not currently support implenmentation of Access Policies for tables, Containers, queues etc.
Please use RBAC instead.

Changes in this version:
  - Breaking changes from v2.x
  - Removed Private Endpoint resources. Use the separate private\_endpoint module if you need a PE.

Future changes to include:
  - Update Azurerm provider to use 3.29.x, Additional attributes available.
  - Add options for choosing different file authentication methods (AD)
  - Options to change tier and protocol for shares.
  - Identity-based authentication (Active Directory) for Azure file shares

## Example - default
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.20.0"
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
}
```

## Example - Create Shares, Containers, Queues & Tables
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.20.0"
    }
  }
}

provider "azurerm" {
  features {}
}


# --------------------------------------------------------------
# Storage Account Module needs a Resource Group
# --------------------------------------------------------------

resource "azurerm_resource_group" "rg_testpe" {
  name     = "rg-exfull-sa"
  location = "uksouth"
}


# --------------------------------------------------------------
# Deploy the module being tested (Storage Account)
# --------------------------------------------------------------

module "storage_account" {
  # source is set to use local path to test the latest version. 
  source = "../../"

  #source  = "andrewCluey/storage-account/azurerm"
  #version = "3.0.0"
  
  storage_account_name   = "samodexdev87t7t"
  location               = azurerm_resource_group.rg_testpe.location
  sa_resource_group_name = azurerm_resource_group.rg_testpe.name
  blob_containers        = ["z-blob", "default", "autotest", "x-blob"]
  storage_queues         = ["dev-queue", "app-queue"]
  storage_tables         = ["appTable", "devTable"]
  storage_shares         = ["share-f", "s-drive"]
  default_action         = "Deny"
  bypass_services        = []                # Try to avoid adding bypass services as this opens up access to ALL Azure customers.
  allowed_public_ip      = ["86.185.241.33"] # If default_action is set to `Deny`, ensure the public IP where Terraform runs from still has access.
}


# --------------------------------------------------------------
# Example Outputs
# --------------------------------------------------------------

output "queues_created" {
  description = "A list of all the Storage Queues created."
  value       = module.storage_account.queues
}

output "primary_blob_endpoint" {
  description = "The URL of the Primary Storage Account Blob Endpoint."
  value       = module.storage_account.primary_blob_endpoint
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | The Storage Tier for the new Account. Options are 'Standard' or 'Premium' | `string` | `"Standard"` | no |
| <a name="input_allowed_public_ip"></a> [allowed\_public\_ip](#input\_allowed\_public\_ip) | A list of public IP or IP ranges in CIDR Format. Private IP Addresses are not permitted. | `list(string)` | `[]` | no |
| <a name="input_allowed_subnet_ids"></a> [allowed\_subnet\_ids](#input\_allowed\_subnet\_ids) | A list of virtual network subnet ids to to secure the storage account. | `list(string)` | `[]` | no |
| <a name="input_blob_containers"></a> [blob\_containers](#input\_blob\_containers) | List all the blob containers to create. | `list(any)` | `[]` | no |
| <a name="input_bypass_services"></a> [bypass\_services](#input\_bypass\_services) | Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices. Empty list to remove it. | `list(string)` | `[]` | no |
| <a name="input_datalake_v2"></a> [datalake\_v2](#input\_datalake\_v2) | Enabled Hierarchical name space for Data Lake Storage Gen 2 | `bool` | `false` | no |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow. | `string` | `"Allow"` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region of where the Storage Account & Private Endpoint are to be created. | `string` | `"uksouth"` | no |
| <a name="input_repl_type"></a> [repl\_type](#input\_repl\_type) | The replication type required for the new Storage Account. Options are LRS; GRS; RAGRS; ZRS | `string` | `"GRS"` | no |
| <a name="input_sa_resource_group_name"></a> [sa\_resource\_group\_name](#input\_sa\_resource\_group\_name) | The name of a Resource Group to deploy the new Storage Account into. | `string` | n/a | yes |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | The name to assign to the new Storage Account. | `string` | n/a | yes |
| <a name="input_storage_queues"></a> [storage\_queues](#input\_storage\_queues) | A list of Storage Queues to be created. | `list(string)` | `[]` | no |
| <a name="input_storage_shares"></a> [storage\_shares](#input\_storage\_shares) | A list of Shares to create within the new Storage Acount. | `list(string)` | `[]` | no |
| <a name="input_storage_tables"></a> [storage\_tables](#input\_storage\_tables) | A list of Storage Tables to be created. | `list(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | tags to apply to the new resources | `map(string)` | `null` | no |
| <a name="input_tls_ver"></a> [tls\_ver](#input\_tls\_ver) | Minimum version of TLS that must be used to connect to the storage account | `string` | `"TLS1_2"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_containers"></a> [containers](#output\_containers) | A list of all the blob containers that have been created (if specified). |
| <a name="output_id"></a> [id](#output\_id) | The ID of the newly created Storage Account. |
| <a name="output_primary_blob_endpoint"></a> [primary\_blob\_endpoint](#output\_primary\_blob\_endpoint) | The endpoint URL for blob storage in the primary location. |
| <a name="output_queues"></a> [queues](#output\_queues) | A list of all the storage queues that have been created (if specified). |
| <a name="output_shares"></a> [shares](#output\_shares) | A list of all the File Shares that have been created (if specified). |
| <a name="output_storage_account_name"></a> [storage\_account\_name](#output\_storage\_account\_name) | The name of the new Storage Account. |
| <a name="output_storage_name"></a> [storage\_name](#output\_storage\_name) | The primary blob endpoint. |
| <a name="output_tables"></a> [tables](#output\_tables) | A list of all the storage tables that have been created (if specified). |
<!-- END_TF_DOCS -->