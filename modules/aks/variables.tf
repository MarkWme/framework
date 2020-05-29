variable "location" {
    type = string
    default     = "westeurope"
    description = "The location for the deployments"
}

variable "name" {
    type = string
    default = "aks"
    description = "Used as part of the naming for the resources"
}

variable "resource_group_name" {
    type = string
    default = "p-rg-euw-core"
    description = "The resource group where the AKS cluster will be deployed"
}

variable "azure_region_code" {
  description = "A three character code used to indicate which region a resource is deployed to. Used as part of the resource name"
}

variable "environment" {
  description = "This will be used to add a prefix to resources (d/t/p) to indicate if a resource is part of a dev, test or production environment"
}

variable "use_preview_version" {
  type = bool
  default = false
  description = "If set to false, the latest GA version of Kubernetes will be deployed. If set to true, the latest preview version will be used"
}
variable "kubernetes_version" {
    type = string
    default = "1.16.7" # Latest GA version of Kubernetes in AKS as at 6th May 2020
    description = "The version of Kubernetes to deploy"
}

variable "kubernetes_version_prefix" {
    type = string
    default = null # Latest GA version of Kubernetes in AKS as at 6th May 2020
    description = "The version of Kubernetes to deploy"
}

variable "vm_sku" {
    type = string
    default = "Standard_D2s_v3"
    description = "The SKU to be used for this virtual machine"
}

variable "virtual_network_name" {
  type = string
  description = "The name of the virtual network that AKS will be configured to use. A subnet will be created in this virtual network"
}

variable "aks_subnet_address_prefix" {
  type = string
  description = "Address prefix to use for the AKS subnet - i.e. 10.0.1.0/24"  
}

variable "enable_kured" {
  type = bool
  default = false
  description = "Enable kured"
}

variable "enable_keda" {
  type = bool
  default = false
  description = "Enable KEDA"
}

variable "enable_agic" {
  type = bool
  default = false
  description = "Enable Application Gateway Ingress Controller"
}

variable "aks_agic_subnet_address_prefix" {
  type = string
  default = null
  description = "Address prefix to use for the Application Gateway Ingress Controller subnet - i.e. 10.0.2.0/24"  
}

variable "admin_username" {
  type = string
  default = "guvnor"
  description = "Username for the local administrator user account"
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

variable "enable_windows_containers" {
  type = bool
  default = false
  description = "If set to true, a node pool for Windows containers will be created"
}

variable "minimum_node_count" {
  default = 1
  description = "Minimum number of nodes in the scale set"
}

variable "maximum_node_count" {
  default = 10
  description = "Maximum number of nodes in the scale set"
}

variable "node_count" {
  default = 3
  description = "Number of nodes initially deployed in the scale set"
}

variable "log_analytics_workspace_id" {
  type = string
  default = false
  description = "ID of the Log Analytics Workspace to connect to"
}

variable "enable_route_table" {
  type = bool
  default = false
  description = "Set this to true if a route table needs to be assigned to the subnet"
}

variable "route_table_id" {
  type = string
  default = null
  description = "ID of the Route Table to assign to this subnet"
}


variable "network_policy" {
  type = string
  default = null
  description = "Which network policy type to use. Valid options are azure or calico"
}
