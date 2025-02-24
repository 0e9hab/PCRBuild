#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-NetworkWatcherConfiguration
/*
Section: 7.6.2. Enable Network Watcher
*/
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_watcher
resource "azurerm_network_watcher" "customer_network_watcher" {
  location = var.location
  name = "vf-core-${var.country_code}-network-watcher"
  resource_group_name = azurerm_resource_group.vf_core_resources_rg.name
}
