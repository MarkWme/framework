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

variable "network_number" {
  type = string
  default = "0"
  description = "Network identifier - the second octet of the IP address - i.e. 10.x.0.0"
}

variable "key_vault_id" {
  type        = string
  description = "The name of the Key Vault instance where the SSH key, Client ID and Client Secret for the AKS nodes is stored. Just the name of the vault, not the URI"
}

variable "ssh_key_name" {
  type = string
  description = "The name of the Key Vault secret that holds the SSH key to be used for the AKS nodes"
}

variable "enable_auto_scaling" {
  type = bool
  default = true
  description = "Should auto scaling be enabled?"
}

variable "enable_rbac" {
  type = bool
  default = true
  description = "Should RBAC be enabled?"
}

variable "enable_pod_security_policy" {
  type = bool
  default = false
  description = "Should pod security policies be enabled?"
}

variable "enable_private_link" {
  type = bool
  default = false
  description = "Should private link be enabled?"
}

variable "log_analytics_workspace_id" {
  type = string
  default = false
  description = "ID of the Log Analytics Workspace to connect to"
}

variable "route_table_id" {
  type = string
  default = "0"
  description = "ID of the Route Table to assign to this subnet"
}
