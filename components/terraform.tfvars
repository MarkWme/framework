name = "res"
azure_region = "westeurope"
environment = "development"
core_resource_group_name = "p-rg-euw-core"
core_key_vault_name = "p-kv-euw-core"
core_virtual_network_name = "p-vn-euw-core"
core_general_subnet_name = "p-vn-euw-core-sn-general"
core_ssh_key_name = "ssh-public-key"
core_log_analytics_workspace_name = "p-la-euw-core"
networks = {
    virtual_network                = "10.0.0.0/16",
    firewall_subnet                = "10.0.0.0/26",
    bastion_subnet                 = "10.0.0.64/26",
    jumpbox_subnet                 = "10.0.0.128/26",
    aks_subnet                     = "10.0.1.0/24",
    aks_agic_subnet                = "10.0.2.0/24",
    general_subnet                 = "10.0.100.0/24",

    private_aks_virtual_network    = "10.1.0.0/16",
    private_aks_subnet             = "10.1.1.0/24"
}