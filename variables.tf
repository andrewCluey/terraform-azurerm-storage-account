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
  # add validation
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
  description = "Enabled Hierarchical name space for Data Lake Storage Gen 2"
  type        = bool
  default     = false
}

variable "tls_ver" {
  description = "Minimum overison of TLS that must be used to connect to the storage account"
  type        = string
  default     = "TLS1_2"
}

variable "storage_shares" {
  type        = list(string)
  description = "A list of Shares to create wqithin the new Storage Acount."
  default     = []
}

variable "default_action" {
  type        = string
  description = "Specifies the default action of allow or deny when no other rules match. Valid options are Deny or Allow."
  default     = "Allow"
}

variable "allowed_public_ip" {
  type        = list(string)
  description = "A list of public IP or IP ranges in CIDR Format. Private IP Addresses are not permitted."
  default     = []
}

variable "bypass_services" {
  type        = list(string)
  description = "Specifies whether traffic is bypassed for Logging/Metrics/AzureServices. Valid options are any combination of Logging, Metrics, AzureServices. Empty list to remove it."
  default     = []
}

variable "allowed_subnet_ids" {
  type        = list(string)
  description = "A list of virtual network subnet ids to to secure the storage account."
  default     = []
}


