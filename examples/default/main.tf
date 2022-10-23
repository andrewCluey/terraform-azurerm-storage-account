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
  location = "westeurope"
}

# Creates Storage Account in default location (WestEurope).
module "storage_account" {
  source  = "andrewCluey/storage-account/azurerm"
  version = "2.0.0"

  storage_account_name    = "sasimple83e32q"
  sa_resource_group_name  = azurerm_resource_group.rg_testpe.name
  blob_containers         = local.blob_containers_tocreate
}
