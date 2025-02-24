#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-MicrosoftEntraIDTenantConfigurationDeployment

data "azurerm_client_config" "current" {}

data "azuread_user" "admin_user" {
  user_principal_name = "admin@${var.company_name}.onmicrosoft.com"
}

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group
resource "azuread_group" "vf_core_keyvault_mgmt" {
  display_name = "vf-core-keyvault-mgmt"
  description = "Allows the member to manage the Vodafone deployed Key Vault instance"
  owners = [data.azuread_user.admin_user.object_id]
  members = try([data.azuread_user.admin_user.object_id, data.azurerm_client_config.current.object_id])
  security_enabled = true
}

resource "azuread_group_member" "vf_core_keyvault_mgmt_member" {
  count = "${var.customer_subscription_owner_firstname}${var.customer_subscription_owner_lastname}" != "" ? 1 : 0
  group_object_id  = try(azuread_group.vf_core_keyvault_mgmt.id, null)
  member_object_id = try(azuread_user.create_subscription_owner[0].id , null)
  depends_on = [azuread_user.create_subscription_owner]
}

resource "azuread_group" "vf_core_subscription_owner" {
  display_name = "vf-core-subscription-owner"
  description = "Allows the member to manage the subscription as the owner"
  owners = try([azuread_user.create_subscription_owner[0].object_id],[data.azurerm_client_config.current.object_id])
  members = try([azuread_user.create_subscription_owner[0].object_id],[])
  security_enabled = true
}

resource "azuread_group" "vf_core_subscription_contributor" {
  count = lower(var.country_code) != "es" ? 0 : 1
  display_name = "vf-core-subscription-contributor"
  description = "Allows the member to manage the subscription as a contributor"
  owners = try([azuread_user.create_subscription_contributor[0].object_id],[data.azurerm_client_config.current.object_id])
  members = try([azuread_user.create_subscription_contributor[0].object_id],[])
  security_enabled = true
}

resource "azuread_group" "vf_core_cost_management" {
  display_name = "vf-core-cost-management"
  description = "Allows the member to view cost management dashboards and billing data"
  owners = try([azuread_user.create_subscription_owner[0].object_id],[data.azurerm_client_config.current.object_id])
  security_enabled = true
}

resource "azuread_group" "vf-core-subscription-level1-support" {
  count = lower(var.country_code) != "pt" || lower(var.country_code) != "al" ? 1 : 0
  display_name = "vf-core-subscription-level1-support"
  description = "Allows the member of the group to provide L1 support"
  security_enabled = true
}

resource "azuread_group" "vf-core-subscription-level2-support" {
  count = lower(var.country_code) != "pt" || lower(var.country_code) != "al" ? 1 : 0
  display_name = "vf-core-subscription-level2-support"
  description = "Allows the member of the group to provide L2 support"
  security_enabled = true
}


/*
Section: 6.1.2. Entra ID Users
*/

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/user
resource "azuread_user" "create_subscription_owner" {
  count = "${var.customer_subscription_owner_firstname}${var.customer_subscription_owner_lastname}" != "" ? 1 : 0
  display_name = "${var.customer_subscription_owner_firstname} ${var.customer_subscription_owner_lastname}"
  password = random_password.customer_subscription_owner_password.result
  user_principal_name = "${var.customer_subscription_owner_firstname}.${var.customer_subscription_owner_lastname}@${var.company_name}.onmicrosoft.com"
}

resource "random_password" "customer_subscription_owner_password" {
  length = 16
  special = true
  override_special = "!@#$"
  lower = true
  numeric = true
  upper = true
}

resource "azuread_user" "create_subscription_contributor" {
  count = "${var.customer_subscription_contributor_firstname}${var.customer_subscription_contributor_lastname}" != "" ? 1 : 0
  display_name = "${var.customer_subscription_contributor_firstname} ${var.customer_subscription_contributor_lastname}"
  password = random_password.customer_subscription_contributor_password.result
  user_principal_name = "${var.customer_subscription_contributor_firstname}.${var.customer_subscription_contributor_lastname}@${var.company_name}.onmicrosoft.com"
}

#https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "customer_subscription_contributor_password" {
  length = 16
  special = true
  override_special = "!@#$"
  lower = true
  numeric = true
  upper = true
}

output "object_id" {
  value = azuread_group.vf_core_keyvault_mgmt.object_id
}

output "customer_subscription_owner_username" {
  value = try(azuread_user.create_subscription_owner[0].object_id,"Customer Subscription Owner not defined")
}

output "customer_subscription_owner_email" {
  value = try(azuread_user.create_subscription_owner[0].user_principal_name,"Customer Subscription Owner not defined")
}

output "customer_subscription_owner_password" {
  value = try(azuread_user.create_subscription_owner[0].password,"Customer Subscription Owner not defined")
}


output "customer_subscription_contributor_username" {
  value = try(azuread_user.create_subscription_contributor[0].object_id,"Customer Subscription Contributor not defined")
}

output "customer_subscription_contributor_email" {
  value = try(azuread_user.create_subscription_contributor[0].user_principal_name,"Customer Subscription Contributor not defined")
}

output "customer_subscription_contributor_password" {
  value = try(azuread_user.create_subscription_contributor[0].password,"Customer Subscription Contributor not defined")
}
