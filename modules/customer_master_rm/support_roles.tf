#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-CustomAzureSubscriptionRoleConfiguration
/*
Section: 7.11.1. vf-core-level2-support JSON Role definition
*/
  
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition
resource "azurerm_role_definition" "vf-core-level2-support" {
  assignable_scopes = [data.azurerm_subscription.current.id]
  name = "vf-core-level2-support"
  description = "Provides the permissions required to for Vodafone level 2 support"
  scope = data.azurerm_subscription.current.id
  permissions {
    actions = [
      "Microsoft.Authorization/locks/read",
      "Microsoft.Authorization/locks/write",
      "Microsoft.Authorization/locks/delete",
      "Microsoft.Authorization/policyAssignments/read",
      "Microsoft.Authorization/policyAssignments/write",
      "Microsoft.Authorization/policyAssignments/delete",
      "Microsoft.Authorization/policyAssignments/exempt/action",
      "Microsoft.Authorization/policies/audit/action",
      "Microsoft.Authorization/policies/auditIfNotExists/action",
      "Microsoft.Authorization/policies/deny/action",
      "Microsoft.Authorization/policies/deployIfNotExists/action",
      "Microsoft.Authorization/policyAssignments/privateLinkAssociations/read",
      "Microsoft.Authorization/policyAssignments/privateLinkAssociations/write",
      "Microsoft.Authorization/policyAssignments/privateLinkAssociations/delete",
      "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/read",
      "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/write",
      "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/delete",
      "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/privateEndpointConnections/read",
      "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/privateEndpointConnections/write",
      "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/privateEndpointConnections/delete",
      "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/privateEndpointConnectionProxies/read",
      "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/privateEndpointConnectionProxies/write",
      "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/privateEndpointConnectionProxies/delete",
      "Microsoft.Authorization/policyAssignments/resourceManagementPrivateLinks/privateEndpointConnectionProxies/validate/action",
      "Microsoft.Authorization/policyDefinitions/read",
      "Microsoft.Authorization/policyDefinitions/write",
      "Microsoft.Authorization/policyDefinitions/delete"
    ]
    data_actions = []
    not_actions = []
    not_data_actions = []
  }
}
