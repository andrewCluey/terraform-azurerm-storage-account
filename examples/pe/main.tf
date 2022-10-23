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
