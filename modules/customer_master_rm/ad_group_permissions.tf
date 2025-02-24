#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-MicrosoftEntraIDTenantConfigurationDeployment
/*
Section: 6.1.1. Azure Active Directory Groups
*/

data "azuread_group" "vf_core_subscription_owner" {
  display_name = "vf-core-subscription-owner"
}

data "azuread_group" "vf_core_subscription_contributor" {
  count = lower(var.country_code) != "es" ? 0 : 1
  display_name = "vf-core-subscription-contributor"
}

data "azuread_group" "vf_core_cost_management" {
  display_name = "vf-core-cost-management"
}

data "azuread_group" "vf_core_keyvault_mgmt" {
  display_name = "vf-core-keyvault-mgmt"
}

data "azuread_group" "vf-core-subscription-level1-support" {
  count = lower(var.country_code) != "pt" || lower(var.country_code) != "al" ? 1 : 0
  display_name = "vf-core-subscription-level1-support"
}

data "azuread_group" "vf-core-subscription-level2-support" {
  count = lower(var.country_code) != "pt" || lower(var.country_code) != "al" ? 1 : 0
  display_name = "vf-core-subscription-level2-support"
}

data "azuread_group" "vf-core-key-vault-mgmt" {
display_name = "vf-core-keyvault-mgmt"
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "vf_core_keyvault_mgmt_keyvault_adminstrator" {
  scope = data.azurerm_subscription.current.id
  role_definition_name = "Key Vault Administrator"
  principal_id = data.azuread_group.vf_core_keyvault_mgmt.object_id
}

resource "azurerm_role_assignment" "vf-core-subscription-level1-support_Cost_Management_Reader" {
  count = lower(var.country_code) != "pt" || lower(var.country_code) != "al" ? 1 : 0
  scope = data.azurerm_subscription.current.id
  role_definition_name = "Cost Management Reader"
  principal_id = data.azuread_group.vf-core-subscription-level1-support[count.index].object_id
}

resource "azurerm_role_assignment" "vf-core-subscription-level1-support_Reader" {
  count = lower(var.country_code) != "pt" || lower(var.country_code) != "al" ? 1 : 0
  scope = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id = data.azuread_group.vf-core-subscription-level1-support[count.index].object_id
}

resource "azurerm_role_assignment" "vf-core-subscription-level2-support_Contributor" {
  count = lower(var.country_code) != "pt" || lower(var.country_code) != "al" ? 1 : 0
  scope = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id = data.azuread_group.vf-core-subscription-level2-support[count.index].object_id
}
resource "azurerm_role_assignment" "vf-core-subscription-level2-support_vf-core-level2-support" {
  count = lower(var.country_code) != "pt" || lower(var.country_code) != "al" ? 1 : 0
  scope = data.azurerm_subscription.current.id
  role_definition_id = azurerm_role_definition.vf-core-level2-support.role_definition_resource_id
  principal_id = data.azuread_group.vf-core-subscription-level2-support[count.index].object_id
}

resource "azurerm_role_assignment" "vf_core_subscription_owner" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
  principal_id         = data.azuread_group.vf_core_subscription_owner.object_id
}

resource "azurerm_role_assignment" "vf_core_subscription_contributor" {
  count = lower(var.country_code) != "es" ? 0 : 1
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_group.vf_core_subscription_contributor[count.index].object_id
}

resource "azurerm_role_assignment" "vf_core_cost_management_Cost_Management_Reader" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Cost Management Reader"
  principal_id         = data.azuread_group.vf_core_cost_management.object_id
}

resource "azurerm_role_assignment" "managed_identity_sa_key_vault_cryptoservice_encryption" {
  scope = azurerm_key_vault.vf_core_kv.id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id = azurerm_user_assigned_identity.managed_identity_sa.principal_id
  depends_on = [azurerm_key_vault.vf_core_kv]
}
