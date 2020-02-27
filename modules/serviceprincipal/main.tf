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
/*  provisioner "local-exec" {
  command = <<EOF
until az ad sp show --id ${azuread_service_principal.service_principal.application_id}
do
  echo "Waiting for service principal..."
  sleep 3
done
EOF
  }*/
}

# az ad sp list --query "[].displayName" --show-mine | grep "p-sp-westeurope-aks-private-01"

resource "azurerm_key_vault_secret" "service_principal_client_id" {
  name         = format("%s-client-id", var.service_principal_name)
  value        = azuread_service_principal.service_principal.application_id
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "service_principal_client_secret" {
  name         = format("%s-client-secret", var.service_principal_name)
  value        = azuread_service_principal_password.service_principal.value
  key_vault_id = var.key_vault_id
}