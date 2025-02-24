#https://confluence.tools.aws.vodafone.com/display/CSAR/Azure+Tenant+and+Subscription+Deployment+Blueprint#AzureTenantandSubscriptionDeploymentBlueprint-AzureSubscriptionConfigurationDeployment
/*
Section: 7.1. Default Vodafone Resource Group and Region
*/

#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-DefaultVodafoneResourceGroupandRegion
resource "azurerm_resource_group" "vf_core_resources_rg" {
  location = var.location
  name = "vf-core-${var.country_code}-resources-rg"
  tags = var.default_tags
}

/*
Section: 6.1.3 Entra ID User Assigned Managed Identities
*/
  
#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-EntraIDUserAssignedManagedIdentities
resource "azurerm_user_assigned_identity" "managed_identity_sa" {
  name                = "vf-core-managed-identity-sa"
  location            = var.location
  resource_group_name = azurerm_resource_group.vf_core_resources_rg.name
}

resource "azurerm_user_assigned_identity" "managed_identity_ap" {
  count = lower(var.is_uk_official) == "gb-official" ? 1 : 0
  name                = "vf-core-managed-identity-ap"
  location            = var.location
  resource_group_name = azurerm_resource_group.vf_core_resources_rg.name
}

output "resource_id" {
  value = azurerm_resource_group.vf_core_resources_rg.id
}
