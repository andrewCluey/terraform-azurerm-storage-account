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

variable "pe_subnet_id" {
  description = "The ID of the subnet where the Private Endpoint will be created."
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

variable "resource_type" {
  description = "Type : LIST. The Container type to create. Can be blob, file, queue,table."
  type        = list(string)
  default     = ["blob"]
}


variable "private_dns_zone_name" {
  description = "The name of the privatelink DNS zone in Azure to register the Private Endpoint resource type."
  type        = string
}

variable "private_dns_zone_id" {
  description = "The ID of the privatelink DNS zone in Azure to register Private Endpoints. Use a Data lookup block in the calling code if not known."
  type        = string
}

variable "provider_alias" {
  description = "Add a value to this variable if the DNS Private Zone is in a separate subscription"
  type        = string
  default     = "azurerm"
}

variable "tls_ver" {
  description = "Minimum overison of TLS that must be used to connect to the storage account"
  type        = string
  default     = "TLS1_2"
}
