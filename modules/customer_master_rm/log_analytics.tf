#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-DeployingaLogAnalyticsWorkspace
/*
Section: 7.4. Deploying Log Analytics
*/

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
resource "azurerm_log_analytics_workspace" "vf_core_log_analytics" {
  location = var.location
  name = "vf-core-log-analytics"
  resource_group_name = azurerm_resource_group.vf_core_resources_rg.name
  sku = "PerGB2018"
  tags = var.default_tags
}
