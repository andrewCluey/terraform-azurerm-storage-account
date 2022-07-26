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


# As with all Terraform modules, we can use local values and create new resources 
# for ensuring all dependencies (Resource Groups, betworks etc) are fed into the module for testing.
# Also, to carry out any necessary post-processing of the results from the module in preparation for writing test assertions.
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

locals {
  blob_containers_tocreate = ["z-blob", "default", "u2-blob", "autotest", "f-blob", "x-blob" ]
  sorted_blobs_tocreate = sort(local.blob_containers_tocreate)
  sort_blob_output      = sort(module.storage_account.blobs)
}


module "storage_account" {
  source   = "../../"

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
  description = "description"
  value       = local.sort_blob_output
}

output "private_endpoint_ip_address" {
  value       = module.storage_account.private_endpoint_ip_address
}
