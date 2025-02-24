#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-Resourcelocks

/*
Section: 7.10. Resource locks
*/

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock
resource "azurerm_management_lock" "resource_group_level" {
  name       = "vf-core-rg-lock"
  scope      = var.resource_id
  lock_level = "CanNotDelete"
  notes      = "Resource group lock added to prevent accidental deletion"
}
