# Linux VM Module

This module deploys a Linux VM running Ubuntu 18.04 in Azure.

It creates

- A Public IP address
- A Network Interface bound to the public IP address and the subnet specified
- A Network Security Group that allows SSH inbound access, bound to the Network Interface
- A Virtual Machine with a system assigned identity
- Optional additional data disks
