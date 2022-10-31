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
  name     = "rg-testshare-sa"
  location = "uksouth"
}


# --------------------------------------------------------------
# Deploy the module being tested (Storage Account)
# --------------------------------------------------------------

# As with all Terraform modules, we can use local values and create new resources.
# Also, we can use `locals` to carry out any post-processing of Outputs
# in preparation for writing test assertions.
locals {
  shares_tocreate = ["default", "test", "b-share"]
}


# We deploy a storage account, several Shares and a Private Endpoint.
module "storage_account" {
# source is always "../.." for test suite configurations.
  source = "../../"

  storage_account_name    = "satestsharesuyt86"
  sa_resource_group_name  = azurerm_resource_group.rg_testpe.name
  storage_shares          = local.shares_tocreate
}



# --------------------------------------------------------------
# Test Assertions
# --------------------------------------------------------------

locals {
  # We don't know in what order the containers will be created.
  # So we `sort` the output alphabetically. 
  sorted_shares_tocreate = sort(local.shares_tocreate)
  sort_share_output      = sort(module.storage_account.shares)
}

resource "test_assertions" "storage_blob" {
  # "component" serves as a unique identifier for this particular set of assertions in the test results.
  component = "test_shares"

  # equal and check blocks serve as the test assertions.
  # The labels on these blocks are unique identifiers for the assertions, to allow more easily tracking changes
  # in success between runs.
  equal "shares_created" {
    description = "Confirm the names of the storage shares created and that it matches what we expect."
    want        = local.sorted_shares_tocreate 
    got         = local.sort_share_output
  }
}
