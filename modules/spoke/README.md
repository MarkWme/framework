# Core Infrastructure Module

This module deploys resources that might typically form a set of common services that could be shared across a subscription.

### Resources Deployed

- Resource Group
- Log Analytics Workspace
- Virtual Network
- Azure Key Vault
- Azure Container Registry

An SSH public key is uploaded to the Azure Key Vault instance, which is then used by other modules.