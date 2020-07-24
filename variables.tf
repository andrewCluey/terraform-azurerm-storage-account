# #######################################################
# Commmon variables. Usually required across ALL modules.
# #######################################################
variable "tags" {
  description = "tags to apply to the new resources"
}

variable "location" {
  description = "The Azure Region of where the Storage Account & Private Endpoint are to be created."
  type        = string
  default     = "West Europe"
}

# ##########################################
# Variables for use within this module only.
# ##########################################
variable "sa_resource_group_name" {
  description = "The name of a Resource Group to deploy the new Storage Account into."
  type        = string
  default     = null
}

variable "pe_vnet_resource_group_name" {
  description = "The name of the Resource group where the vNET for the Private Endpoint exists."
  type        = string
}

variable "pe_vnet_name" {
  description = "The name of the vNet where the Private Endpoint subnet is located."
  type        = string
}

variable "pe_subnet_name" {
  description = "The name of the subnet where the Private Endpoint will be created."
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

variable "datalake_v2" {
  description = "Enabled Hierarchical name space for Data Lake Storage gen 2"
  type        = bool
  default     = false
}

variable "private_blob_dns_zone_name" {
  description = "The name of the privatelink blob DNS zone in Azure to register Blob Private Endpoints"
  type        = string
}

variable "private_blob_dns_zone_id" {
  description = "The ID of the privatelink blob DNS zone in Azure to register Blob Private Endpoints. Use a Data lookup block in the calling code if not known."
  type        = string
}
