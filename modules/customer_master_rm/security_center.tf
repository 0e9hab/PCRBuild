#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-SecuritySettings
/*
Section: 7.6.1. Security Center Configuration
*/

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_contact
resource "azurerm_security_center_contact" "current_account" {
  count = var.customer_security_contact_email != "" ? 1 : 0
  alert_notifications = true
  alerts_to_admins = true
  email = var.customer_security_contact_email
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/security_center_automation
#resource "azurerm_security_center_automation" "log-export" {
#name = "continuous_export"
#location = azurerm_resource_group.vf_core_resources_rg.location
#resource_group_name = azurerm_resource_group.vf_core_resources_rg.name
#action {
#  type = "loganalytics"
#  resource_id = azurerm_log_analytics_workspace.vf_core_log_analytics.id
#}
#source {
#  event_source = "Alerts"
#  rule_set {
#    rule {
#      property_path = "Severity"
#      operator = "Equals"
#      expected_value = "High"
#      property_type = "String"
#    }
#    rule {
#      property_path = "Severity"
#      operator = "Equals"
#      expected_value = "Medium"
#      property_type = "String"
#    }
#  }
#}
#source {
#  event_source = "SecureScores"

#}
#source {
#  event_source = "Assessments"
#  rule_set {
#    rule {
#      property_path = "Severity"
#      operator = "Equals"
#      expected_value = "High"
#      property_type = "String"
#    }
#    rule {
#      property_path = "Severity"
#      operator = "Equals"
#      expected_value = "Medium"
#      property_type = "String"
#    }
#  }
#}
#source {
#  event_source = "RegulatoryComplianceAssessment"
#}
# scopes = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
#}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_policy_assignment
resource "azurerm_subscription_policy_assignment" "cis_policy" {
  for_each = var.security_policies
  name                 = each.key
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = each.value.id
  enforce = false
  parameters = jsonencode({
  "maximumDaysToRotate-d8cf8476-a2ec-4916-896e-992351803c44":{
  "value":365}
  })
}

resource "azurerm_subscription_policy_assignment" "uk_official_and_uk_nhs_policy" {
  count = lower(var.is_uk_official) == "gb-official" ? 1 : 0
  name                 = "UK OFFICIAL and UK NHS"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/3937f550-eedd-4639-9c5e-294358be442e"
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity_ap[count.index].id]
  }
  location = var.location
  enforce = false
}
resource "azurerm_subscription_policy_assignment" "acs_default_initiative" {
  name                 = "ASC Default Initiative"
  display_name         = "ASC Default Initiative"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/microsoft.authorization/policysetdefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
  enforce = false
}
