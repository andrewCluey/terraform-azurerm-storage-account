terraform {
  required_providers {
    # terraform.io/builin/test is an experimental feature to provide native testing in Terraform.
    # This provider is only available when running tests, so you shouldn't be used in non-test modules.
    test = {
      source = "terraform.io/builtin/test"
    }

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
# Storage Account Module doesn't create an Azure Resource Group
# --------------------------------------------------------------

resource "azurerm_resource_group" "rg_testpe" {
  name     = "rg-exfull-sa"
  location = "uksouth"
}


# --------------------------------------------------------------
# Deploy the module being tested (Storage Account)
# --------------------------------------------------------------

# As with all Terraform modules, we can use local values and create new resources.
# Also, we can use `locals` to carry out any post-processing of Outputs
# in preparation for writing test assertions.
locals {
  blob_containers_tocreate = ["z-blob", "default", "u2-blob", "autotest", "f-blob", "x-blob"]

  # The following locals are used for the test assertion resource only.
  # We don't know in what order the containers will be created.
  # So we `sort` the output alphabetically. 
  sorted_blobs_tocreate = sort(local.blob_containers_tocreate)
  sort_blob_output      = sort(module.storage_account.blobs)
}

# We deploy a storage account, several Blob Containers and a Private Endpoint.
# Blob containers as defined in local.blob_containers_tocreate.
module "storage_account" {
  # source is always "../.." for test suite configurations.
  source = "../../"

  storage_account_name         = "sape83e32q"
  location                     = azurerm_resource_group.rg_testpe.location
  sa_resource_group_name       = azurerm_resource_group.rg_testpe.name
  blob_containers              = local.blob_containers_tocreate
  default_action               = "Deny"
  allowed_subnet_ids           = [azurerm_subnet.sn_testpe.id]
  bypass_services              = []
  allowed_public_ip            = ["86.185.250.45"] # If locking down access to specific Private subnets, ensure the Terraform client still retains access.
}


