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

resource "azurerm_resource_group" "rg-default-sa" {
  name     = "rg-testdefault-sa"
  location = "westeurope"
}

# --------------------------------------------------------------
# Deploy the module being tested (Storage Account)
# --------------------------------------------------------------
module "storage_account" {
  # Source is always "../.." for test suite configurations.
  source = "../../"

  storage_account_name   = "sadefault223ihs"
  sa_resource_group_name = azurerm_resource_group.rg-default-sa.name
}


# --------------------------------------------------------------
# Test Assertions
# --------------------------------------------------------------

# The special test_assertions resource type, which belongs to the
# `test provider` we specified in the providers block, is used
# to write out explicit test assertions. 

resource "test_assertions" "storage_blob" {
  # "component" serves as a unique identifier for this particular set of assertions in the test results.
  component = "created_storage_account"

  # equal and check blocks serve as the test assertions.
  # The labels on these blocks are unique identifiers for the assertions.
  # Outputs from the module can be used to find out what was created (`GOT`).
  equal "storage_account_name" {
    description = "Confirm the storage account name."
    want        = "sadefault223ihs"
    got         = module.storage_account.storage_account_name
  }

  ##### future test to add. #####
  /*
  check "url" {
    description = "Do we get a public URL for the Storage Account returned in the output?"
    condition   = "regex for Storage URL or use the `equal` test as we shoudl be able to construct the primary URL."
  }
*/
}
