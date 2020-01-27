resource "random_password" "password" {
  length = 64
}

resource "azuread_application" "service_principal" {
  name                       = var.service_principal_name
}

resource "azuread_service_principal" "service_principal" {
  application_id = azuread_application.service_principal.application_id
}

resource "azuread_service_principal_password" "service_principal" {
  service_principal_id = azuread_service_principal.service_principal.id
  value                = random_password.password.result
  end_date_relative    = "8760h"
}

resource "azurerm_key_vault_secret" "service_principal_client_id" {
  name         = format("%s-client-id", var.service_principal_name)
  value        = azuread_service_principal.service_principal.application_id
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "service_principal_client_secret" {
  name         = format("%s-client-secret", var.service_principal_name)
  value        = random_password.password.result
  key_vault_id = var.key_vault_id
}

output "client_id" {
  value = azuread_service_principal.service_principal.application_id
}

output "client_secret" {
  value = random_password.password.result
}

output "client_id_name" {
  value = format("%s-client-id", var.service_principal_name)
}

output "client_secret_name" {
  value = format("%s-client-secret", var.service_principal_name)
}