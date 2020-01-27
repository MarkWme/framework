# Service Principal Module

This module uses the Azure AD provider to create a service principal with a randomly generated password, then stores the Client ID and Client Secret in an Azure Key Vault instance

### Inputs

| service_principal_name | Name of the service principal |
| key_vault_id | ID of the Key Vault instance where the service principal's Client ID and Client Secret will be stored |

Note that Terraform needs to be running in the context of a user / service principal that has the necessary rights to create service principals and to add secrets to the Key Vault instance specified.