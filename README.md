# Framework

*Used to deploy various Azure services for testing, demonstration and proof of concept development*

## Pre-requisites

- An existing Azure Storage Account (blob) which can be used to store Terraform state data
- An access key for the Azure Storage Account

## Resource created

### Core
* Resource group - p-rg-euw-core
* Virtual network - p-vn-euw-core, 10.0.0.0/16
* Subnet 1 - p-sn-euw-core-001, 10.0.1.0/24
* Azure Key Vault - p-kv-euw-core
* Azure Container Register - pcreuwcore