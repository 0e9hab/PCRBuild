#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-AzureMonitorConfiguration
/*
Section: 7.7.1. Action group configuration
*/

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_action_group
resource "azurerm_monitor_action_group" "vf_core_security-notifications" {
  count = var.customer_security_contact_email != "" ? 1 : 0
  name = "vf-core-security-notifications"
  resource_group_name = azurerm_resource_group.vf_core_resources_rg.name
  short_name = "vf-core-cis"
  email_receiver {
    email_address = var.customer_security_contact_email
    name = "Security Contact"
  }
  tags = var.default_tags
}


resource "azurerm_monitor_action_group" "vf_core_health_notifications" {
  count = var.customer_service_health_contact_email != "" ? 1 : 0
  name = "vf-core-health-notifications"
  resource_group_name = azurerm_resource_group.vf_core_resources_rg.name
  short_name = "vf-core-hlt"
  email_receiver {
    email_address = var.customer_service_health_contact_email
    name = "Service Health Contact"
  }
  tags = var.default_tags
}
