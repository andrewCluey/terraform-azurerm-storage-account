terraform {
  required_providers {
    # terraform.io/builin/test is an experimental feature to provide native testing in Terraform.
    # This provider is only available when running tests, so you shouldn't be used in non-test modules.
    test = {
      source = "terraform.io/builtin/test"
    }

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
  name     = "rg-testpe-sa"
  location = "uksouth"
}
resource "azurerm_virtual_network" "vn_testpe" {
  name                = "testpe-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg_testpe.location
  resource_group_name = azurerm_resource_group.rg_testpe.name
}

resource "azurerm_subnet" "sn_testpe" {
  name                 = "testpe-subnet"
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

  # Following locals used for the test assertion resource only.
  # We don't know in what order the containers will be created.
  # so using the `sort` function, we order the lists alphabetically. 
  sorted_blobs_tocreate = sort(local.blob_containers_tocreate)
  sort_blob_output      = sort(module.storage_account.blobs)
}


# We deploying a storage account, several Blob Containers and a Private Endppouint using the storage-account module.
# Blob containers as defined in local.blob_containers_tocreate.
module "storage_account" {
# source is always "../.."" for test suite configurations,
# because they are placed two sub-directories deep under the main module directory.
  source   = "../../"

  storage_account_name    = "sape83e32q"
  sa_resource_group_name  = azurerm_resource_group.rg_testpe.name
  blob_containers         = local.blob_containers_tocreate
  deploy_private_endpoint = true
  pe_subnet_id            = azurerm_subnet.sn_testpe.id
  private_dns_zone        = {
    name = azurerm_private_dns_zone.dns_testpe.name
    id   = azurerm_private_dns_zone.dns_testpe.id
  }
}


# The special test_assertions resource type, which belongs
# to the test provider we specified in the providers block, is a temporary
# syntax for writing out explicit test assertions.
resource "test_assertions" "storage_blob" {
  # "component" serves as a unique identifier for this particular set of assertions in the test results.
  component = "default_blob"

  # equal and check blocks serve as the test assertions.
  # The labels on these blocks are unique identifiers for the assertions, to allow more easily tracking changes
  # in success between runs.
  equal "blob_containers_created" {
    description = "Confirm the names of the blob containers we create and that it matches what we expect."
    got         = local.sort_blob_output      # local to sort the output from the storage account module alphabetically.
    want        = local.sorted_blobs_tocreate # local to sort our input list of blobs to create alphabetically.
  }




##### future tests to add. #####
/*
  check "url" {
    description = "Do we get a public URL for the Storage Account returned in the output?"
    condition   = "regex for Storage URL or use the `equal` test as we shoudl be able to construct the primary URL."
  }

  check "private_ip" {
    description = "Check the IP address of the new Private Endpoint has the correct subnet address.."
    condition   = can(regex(["10.0.1"], module.storage_account.private_endpoint_ip_address))
  }

  equal "pe_subnet_id" {
    description = "Confirm the Subnet name that the PE is deployed to. Using Module Output."
    got         = azurerm_subnet.sn_testpe.id
    want        = module.storage_account.pe_subnet_id
  }

*/

}
