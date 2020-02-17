# Create a virtual network

resource "azurerm_virtual_network" "virtual-network" {
    name = var.network_name
    location = var.location
    resource_group_name = var.resource_group_name
    address_space = var.address_space
    tags = {
        deployed-by = "terraform"
        timestamp = timestamp()
        description = "Virtual Network"
    }

    lifecycle {
        ignore_changes = [
            tags["timestamp"],
        ]
    }
}

# If peering is enabled, establish peering from the remote network to the newly created network

resource "azurerm_virtual_network_peering" "peer-from-remote" {
    count = var.enable_peering ? 1 : 0
    name                      = format("%s-peer-to%s", var.peer_with_network_name, var.network_name)
    resource_group_name       = var.peer_with_network_resource_group
    virtual_network_name      = var.peer_with_network_name
    remote_virtual_network_id = azurerm_virtual_network.virtual-network.id
    allow_virtual_network_access = true
}

# If peering is enabled, establish peering from the newly created network to the remote network

resource "azurerm_virtual_network_peering" "peer-to-remote" {
    count = var.enable_peering ? 1 : 0
    name                      = format("%s-peer-to%s", var.network_name, var.peer_with_network_name)
    resource_group_name       = var.resource_group_name
    virtual_network_name      = azurerm_virtual_network.virtual-network.name
    remote_virtual_network_id = var.peer_with_network_id
    allow_virtual_network_access = true
}

# If diagnostics logging is enabled, configure diagnostics logs to be sent to Log Analytics

resource "azurerm_monitor_diagnostic_setting" "log-analytics" {
    count = var.enable_diagnostics ? 1 : 0
    name               = format("%s-diagnostics", var.network_name)
    target_resource_id = azurerm_virtual_network.virtual-network.id
    log_analytics_workspace_id = var.log_analytics_workspace_id

    log {
        category = "VMProtectionAlerts"
        enabled  = true

        retention_policy {
        enabled = false
        }
    }
    metric {
        category = "AllMetrics"

        retention_policy {
        enabled = false
        }
    }
}

output "virtual_network_name" {
    value = azurerm_virtual_network.virtual-network.name
}

output "virtual_network_id" {
    value = azurerm_virtual_network.virtual-network.id
}