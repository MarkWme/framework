
output "client_id" {
  value = azuread_service_principal.service_principal.application_id
  description = "The client ID (application ID) for the service principal"
}

output "client_secret" {
  value = azuread_service_principal_password.service_principal.value
  description = "The client secret (password) for the service principal"
}

output "client_id_name" {
  value = format("%s-client-id", var.service_principal_name)
  description = "Name of the key containing the client ID"
}

output "client_secret_name" {
  value = format("%s-client-secret", var.service_principal_name)
  description = "Name of the key containing the client secret"
}