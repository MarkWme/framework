variable "location" {
    type = string
    default     = "westeurope"
    description = "The location for the deployments"
}

variable "role" {
    type = string
    default = "aks"
    description = "A role or other value that will be inserted into the resource name to help identify it"
}

variable "instance_id" {
    type = string
    description = "An instance ID that is used to name resources. This should be an incremental number, i.e. 1 for the first AKS cluster, 2 for the second and so on."
}

variable "resource_group_name" {
    type = string
    default = "p-rg-euw-core"
    description = "The resource group where the AKS cluster will be deployed"
}

variable "kubernetes_version" {
    type = string
    default = "1.15.7" # Latest GA version of Kubernetes in AKS as at 27 Jan 2020
    description = "The version of Kubernetes to deploy"
}

variable "virtual_network_name" {
  type = string
  description = "The name of the virtual network that AKS will be configured to use. A subnet will be created in this virtual network"
}

variable "key_vault_id" {
  type        = string
  description = "The name of the Key Vault instance where the SSH key, Client ID and Client Secret for the AKS nodes is stored. Just the name of the vault, not the URI"
}

variable "ssh_key" {
  type = string
  description = "The name of the Key Vault secret that holds the SSH key to be used for the AKS nodes"
}

variable "enable_auto_scaling" {
  type = bool
  default = true
  description = "Should auto scaling be enabled?"
}