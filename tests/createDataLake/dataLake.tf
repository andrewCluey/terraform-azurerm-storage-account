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

resource "azurerm_resource_group" "rg" {
  name     = "rg-testdatalake-sa"
  location = "uksouth"
}


# --------------------------------------------------------------
# Deploy the module being tested (Storage Account) as Data Lake.
# --------------------------------------------------------------
module "storage_account_datalake" {
# Source is always "../.." for test suite configurations.
  source   = "../../"

  storage_account_name    = "satestdatalake1trd"
  sa_resource_group_name  = azurerm_resource_group.rg.name
  datalake_v2             = true
}


# --------------------------------------------------------------
# Test Assertions
# --------------------------------------------------------------

# The special test_assertions resource type, which belongs to the
# `test provider` we specified in the providers block, is used
# to write out explicit test assertions. 

resource "test_assertions" "storage_account" {
  # "component" serves as a unique identifier for this particular set of assertions in the test results.
  component = "storage_account_name"

  # equal and check blocks serve as the test assertions.
  # The labels on these blocks are unique identifiers for the assertions.
  # Outputs from the module can be used to find out what was created (`GOT`).
  equal "storage_account_name" {
    description = "Confirm the storage account name."
    want        = "satestdatalake1trd"
    got         = module.storage_account_datalake.storage_account_name
  }

}
