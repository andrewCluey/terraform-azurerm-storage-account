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
  name     = "rg-testdetailed-sa"
  location = "uksouth"
}


# --------------------------------------------------------------
# Deploy the module being tested (Storage Account)
# --------------------------------------------------------------

# As with all Terraform modules, we can use local values and create new resources.
# Also, we can use `locals` to carry out any post-processing of Outputs
# in preparation for writing test assertions.
locals {
  shares_to_create     = ["default", "test", "b-share"]
  containers_to_create = ["default", "blob-c", "blob-b"]
  queues_to_create     = ["dev-queue", "app-queue"]
  tables_to_create     = ["appTable", "devTable"]
}


# We deploy a storage account, several Shares and a Private Endpoint.
module "storage_account" {
  # source is always "../.." for test suite configurations.
  source = "../../"

  storage_account_name   = "satestsharesuyt86"
  sa_resource_group_name = azurerm_resource_group.rg_testpe.name
  location               = azurerm_resource_group.rg_testpe.location
  storage_shares         = local.shares_to_create
  storage_tables         = local.tables_to_create
  storage_queues         = local.queues_to_create
  blob_containers        = local.containers_to_create
  repl_type              = "ZRS"
  default_action         = "Allow"
}



# --------------------------------------------------------------
# Test Assertions
# --------------------------------------------------------------

locals {
  # We don't know in what order the containers will be created.
  # So we `sort` the output alphabetically. 
  sorted_shares_to_create     = sort(local.shares_to_create)
  sort_share_output           = sort(module.storage_account.shares)
  sorted_containers_to_create = sort(local.containers_to_create)
  sorted_containers_output    = sort(module.storage_account.containers)
  sorted_tables_to_create     = sort(local.tables_to_create)
  sorted_tables_output        = sort(module.storage_account.tables)
  sorted_queues_to_create     = sort(local.queues_to_create)
  sorted_queues_output        = sort(module.storage_account.queues)
}

resource "test_assertions" "storage_types" {
  # "component" serves as a unique identifier for this particular set of assertions in the test results.
  component = "test_storage_resources"

  # equal and check blocks serve as the test assertions.
  # The labels on these blocks are unique identifiers for the assertions, to allow more easily tracking changes
  # in success between runs.
  equal "shares_created" {
    description = "Confirm the names of the storage shares created and that it matches what we expect."
    want        = local.sorted_shares_to_create
    got         = local.sort_share_output
  }

  equal "containers_created" {
    description = "Confirm the names of the storage Containers created and that it matches what we expect."
    want        = local.sorted_containers_to_create
    got         = local.sorted_containers_output
  }

  equal "tables_created" {
    description = "Confirm the names of the storage tables created and that it matches what we expect."
    want        = local.sorted_tables_to_create
    got         = local.sorted_tables_output
  }

  equal "queues_created" {
    description = "Confirm the names of the storage queues created and that it matches what we expect."
    want        = local.sorted_queues_to_create
    got         = local.sorted_queues_output
  }
}
