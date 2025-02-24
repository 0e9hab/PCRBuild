//Last modified 30/05/2022
#https://confluence.tools.aws.vodafone.com/display/CSAR/Azure+Tenant+and+Subscription+Deployment+Blueprint#AzureTenantandSubscriptionDeploymentBlueprint-AzureActiveDirectoryUsers
data "azurerm_subscription" "current" {}

/*
Section: 5.1.2. Azure Active Directory Groups
*/
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "vbmp-coresubscriptioncontributor" {
  count = var.vbmp_addon ? 1:0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = var.vf_corevbmpprovider_object_id
}

locals {
  provider_registration_list = [
    "Microsoft.Sql",
    "Microsoft.Batch",
    "Microsoft.Network",
    "Microsoft.Cache",
    "Microsoft.Compute",
    "Microsoft.ContainerInstance",
    "Microsoft.ContainerRegistry",
    "Microsoft.DBforMySQL",
    "Microsoft.DocumentDB",
    "Microsoft.EventHub",
    "Microsoft.KeyVault",
    "Microsoft.NotificationHubs",
    "Microsoft.RecoveryServices",
    "Microsoft.Relay",
    "Microsoft.ServiceBus",
    "Microsoft.Storage",
    "Microsoft.Web",
    "microsoft.insights",
    //"Microsoft.HybridData",
  ]

  provider_registration_refined_list = [
    "Microsoft.Batch",
  ]

}

#https://confluence.tools.aws.vodafone.com/display/CSAR/Azure+Tenant+and+Subscription+Deployment+Blueprint#AzureTenantandSubscriptionDeploymentBlueprint-DefaultVodafoneResourceGroupandRegion
/*
Section: 6.1. Registering Resource Providers
*/
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_provider_registration
resource "azurerm_resource_provider_registration" "register" {
  for_each = var.vbmp_addon ? toset(local.provider_registration_refined_list) : []
  name = each.value
}
