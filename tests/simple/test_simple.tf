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


# As with all Terraform modules, we can use local values and specific 
# resource blocks for providing data inputs into the test assertions.
# Also, to carry out any necessary post-processing of the results from the module in preparation for writing test assertions.
resource "azurerm_resource_group" "rg-simple-sa" {
  name     = "rg-testsimple-sa"
  location = "uksouth"
}

locals {
  blob_containers_tocreate = ["z-blob", "default", "u2-blob", "autotest", "f-blob", "x-blob" ]

  # Following locals used for the test assertion resource only.
  # We don't know in what order the containers will be created.
  # By alphabetically sorting the module output and the list of blobs we want to create, we standardise the order. 
  sorted_blobs_tocreate = sort(local.blob_containers_tocreate)
  sort_blob_output      = sort(module.storage_account.blobs)
}


# Here, we are deploying a simple storage account using the storage-account module.
# Creating several blob containers as defined in local.blob_containers_tocreate.
module "storage_account" {
# source is always "../.."" for test suite configurations,
# because they are placed two sub-directories deep under the main module directory.
  source   = "../../"

  storage_account_name    = "sasimple7t68"
  sa_resource_group_name  = azurerm_resource_group.rg-simple-sa.name
  blob_containers         = local.blob_containers_tocreate 
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

##### future test to add. #####
/*
  check "url" {
    description = "Do we get a public URL for the Storage Account returned in the output?"
    condition   = "regex for Storage URL or use the `equal` test as we shoudl be able to construct the primary URL."
  }
*/

}