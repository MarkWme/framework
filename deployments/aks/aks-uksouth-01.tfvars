name = "aks-01"
azure_region = "uksouth"
environment = "development"
virtual_network_resource_group = "p-rg-uks-spoke"
virtual_network_name = "p-vn-uks-spoke"
key_vault_name = "p-kv-euw-core"
key_vault_resource_group = "p-rg-euw-core"
ssh_key_name = "ssh-public-key"
log_analytics_workspace_name = "p-la-euw-core"
log_analytics_resource_group = "p-rg-euw-core"
networks = {
    virtual_network                = "10.2.0.0/16",
    aks_subnet                     = "10.2.1.0/24",
}