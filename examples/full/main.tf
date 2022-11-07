terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 3.20.0"
    }
    http = {
      source = "hashicorp/http"
      version = "3.2.0"
    }
  }
}

provider "http" {}
provider "azurerm" {
  features {}
}


# ---------------------------------------------------------------
# Get TF client Public IP for subsequent access to locked down SA
# ---------------------------------------------------------------

data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

# --------------------------------------------------------------
# Storage Account Module needs a Resource Group
# --------------------------------------------------------------

resource "azurerm_resource_group" "rg" {
  name     = "rg-exfull-sa"
  location = "uksouth"
}


# --------------------------------------------------------------
# Deploy the module being tested (Storage Account)
# --------------------------------------------------------------

module "storage_account" {
  # source is set to use local path for testing the latest version. 
  source = "../../"
  #source  = "andrewCluey/storage-account/azurerm"
  #version = "3.0.0"
  
  storage_account_name   = "samodexdev87t7t"
  location               = azurerm_resource_group.rg.location
  sa_resource_group_name = azurerm_resource_group.rg.name
  blob_containers        = ["z-blob", "default", "autotest", "x-blob"]
  storage_queues         = ["dev-queue", "app-queue"]
  storage_tables         = ["appTable", "devTable"]
  storage_shares         = ["share-f", "s-drive"]
  default_action         = "Deny"
  bypass_services        = []                # Try to avoid adding bypass services as this opens up access to ALL Azure customers.
  allowed_public_ip      = [data.http.ip.response_body] # If default_action is set to `Deny`, ensure the public IP where Terraform runs from still has access.
}


# --------------------------------------------------------------
# Example Outputs
# --------------------------------------------------------------

output "queues_created" {
  description = "A list of all the Storage Queues created."
  value       = module.storage_account.queues
}

output "primary_blob_endpoint" {
  description = "The URL of the Primary Storage Account Blob Endpoint."
  value       = module.storage_account.primary_blob_endpoint
}

output "my_ip" {
  value = data.http.ip.response_body
}
