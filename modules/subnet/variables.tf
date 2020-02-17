variable "resource_group_name" {
  description = "The name of the resource group to create the new subnet in"
}

variable "virtual_network_name" {
  description = "The name of the virtual network to create the subnet in"
}

variable "subnet_name" {
  description = "The name of the subnet"
}

variable "address_prefix" {
    default = "10.0.0.0/24"
    description = "The address space of the subnet to be created"
}

variable "route_table_id" {
    default = null
    description = "If this subnet will have a custom route table provide the route table ID here"
}

variable "use_specific_name" {
    default = false
    description = "If your subnet requires a specific name such as 'AzureFirewallSubnet', set this value to true so that the name doesn't get prefixed with the virtual network name"
}
