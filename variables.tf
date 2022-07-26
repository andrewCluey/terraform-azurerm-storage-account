# #######################################################
# Commmon variables. Usually required across ALL modules.
# #######################################################
variable "tags" {
  description = "tags to apply to the new resources"
  type        = map(string)
  default     = null
}

variable "location" {
  description = "The Azure Region of where the Storage Account & Private Endpoint are to be created."
  type        = string
  default     = "westeurope"
}

# ##########################################
# Variables for use within this module only.
# ##########################################
variable "sa_resource_group_name" {
  description = "The name of a Resource Group to deploy the new Storage Account into."
  type        = string
}

variable "repl_type" {
  description = "The replication type required for the new Storage Account. Options are LRS; GRS; RAGRS; ZRS"
  type        = string
  default     = "GRS"
}

variable "account_tier" {
  description = "The Storage Tier for the new Account. Options are 'Standard' or 'Premium'"
  type        = string
  default     = "Standard"
}

variable "storage_account_name" {
  description = "The name to assign to the new Storage Account."
  type        = string
}

variable "blob_containers" {
  type        = list(any)
  description = "List all the blob containers to create."
  default     = []
}


variable "datalake_v2" {
  description = "Enabled Hierarchical name space for Data Lake Storage gen 2"
  type        = bool
  default     = false
}

/*
## Removed this variable. Fixed default container as Blob.
# Will add new feature to include deployment of other storage resources such as files/queues etc

variable "resource_type" {
  description = "Type : LIST. The Container type to create. Can be blob, file, queue, table."
  type        = list(string)
  default     = ["blob"]
}
*/


variable "pe_subnet_id" {
  description = "The ID of the subnet where the Private Endpoint will be created."
  type        = string
  default     = ""
}

variable "private_dns_zone" {
  type        = any
  default     = {}
  description = <<EOF
  The name and ID of the privatelink DNS zone in Azure to register the Private Endpoint resource type.
  Requires an input map object. EXAMPLE:
  private-dns_zone = {
    name = "privatelink.blob.azure.windows.net"
    id   = "hyoiuhyou-8y98/uhi"
  }
EOF
}

variable "tls_ver" {
  description = "Minimum overison of TLS that must be used to connect to the storage account"
  type        = string
  default     = "TLS1_2"
}


variable "deploy_private_endpoint" {
  type        = bool
  description = "Deploy a private endopoint with the storage accoubnt. True/False."
  default     = false
}
