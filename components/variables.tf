variable "name" {
    type = string
    default     = "coredev"
    description = "This will be used as part of the resource names"
}

variable "core_resource_group_name" {
    type = string
    default     = null
    description = "Resource group where core components are deployed"
}

variable "core_key_vault_name" {
    type = string
    default     = null
    description = "Resource group where Azure Key Vault is deployed"
}

variable "core_virtual_network_name" {
    type = string
    default     = null
    description = "Resource group where Azure Key Vault is deployed"
}

variable "core_log_analytics_workspace_name" {
    type = string
    default     = null
    description = "Resource group where Azure Key Vault is deployed"
}

variable "core_ssh_key_name" {
    type = string
    default     = null
    description = "Resource group where Azure Key Vault is deployed"
}

variable "azure_region" {
    type = string
    default     = "westeurope"
    description = "The Azure Region where all resources will be deployed"
}

variable "environment" {
    type = string
    default = "development"
    description = "This will be used to add a prefix to resources (d/t/p) to indicate if a resource is part of a dev, test or production environment"
}

variable "azure_regions" {
  type = map(string)
  default = {
    westeurope  = "euw"
    northeurope = "eun"
  }
}

variable "environments" {
  type = map(string)
  default = {
    development = "d"
    test        = "t"
    production  = "p"
    temp        = "x"
  }
}

variable "networks" {
  type = map(string)
  default = {}
}

