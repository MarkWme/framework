variable "location" {
  default     = "westeurope"
  description = "The location for the deployments"
}

variable "azure_region_code" {
  description = "A three character code used to indicate which region a resource is deployed to. Used as part of the resource name"
}

variable "environment" {
  description = "This will be used to add a prefix to resources (d/t/p) to indicate if a resource is part of a dev, test or production environment"
}

variable "core_resource_group_name" {
  description = "The name of the network to peer with"
}

variable "core_network_name" {
  description = "The name of the network to peer with"
}

variable "core_network_id" {
  description = "The id of the network to peer with"
}

variable "name" {
    type = string
    default = "aks-private"
    description = "Used as part of the naming for the resources"
}

variable "instance_id" {
    type = string
    description = "An instance ID that is used to name resources. This should be an incremental number, i.e. 1 for the first AKS cluster, 2 for the second and so on."
}

variable "network_id" {
  type = string
  default = "0"
  description = "Network identifier - the second octet of the IP address - i.e. 10.x.0.0"
}

variable "firewall_name" {
  description = "Name of the Firewall resource in the core network"
}

variable "firewall_resource_group_name" {
  description = "Name of the Firewall resource in the core network"
}
variable "firewall_private_ip_address" {
  description = "Private IP address of the firewall"
}

variable "key_vault_id" {
  description = "ID of the Key Vault instance to use"
}

variable "ssh_key_name" {
  description = "Name of the Key Vault secret holding the SSH key"
}

variable "log_analytics_workspace_id" {
  description = "The id of the Log Analytics instance to connect to"
}

