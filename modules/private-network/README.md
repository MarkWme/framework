# Private Network Module

This module deploys resources to form a private, secure network.

- Azure Firewall
- Azure Bastion
- Linux VM

### Azure Firewall

Azure Firewall is used to filter all traffic in and out of your network.

### Azure Bastion

Your resources will be located on networks with private IP address ranges that are inaccessible from the public Internet. Use Azure Bastion to provide a point of entry into your network's private resources.

### Linux VM

At present, Azure Bastion is in preview and is not available in all regions. The Linux VM provides a bastion / jumpbox that you can connect to and use that to access private resources.