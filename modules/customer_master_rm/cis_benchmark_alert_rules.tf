#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-CISBenchmarkAzureMonitorAlertRules
/*
Section: 7.7.2. CIS Benchmark Alerts Rules
*/
locals {
  cis_mertics = {
    "CIS 5.2.1 - Create Azure Policy Assignment Detected" = {
      description = "An Azure Policy assignment has been created"
      category = "Administrative"
      operation_name = "Microsoft.Authorization/policyAssignments/write"
      resource_type = "microsoft.authorization/policyassignments"
    }
    "CIS 5.2.2 - Azure Policy Assignment Deletion Detected" = {
      description = "An Azure Policy assignment has been deleted"
      category = "Administrative"
      operation_name = "Microsoft.Authorization/policyAssignments/delete"
      resource_type = "microsoft.authorization/policyassignments"
    }
    "CIS 5.2.3 - Create or Update Azure Network Security Group Detected" = {
      description = "A network security group has been created or updated"
      category = "Administrative"
      operation_name = "Microsoft.Network/networkSecurityGroups/write"
      resource_type = "microsoft.network/networksecuritygroups"
    }
    "CIS 5.2.4 - Delete Azure Network Security Group Detected" = {
      description = "A network security group has been deleted"
      category = "Administrative"
      operation_name = "Microsoft.Network/networkSecurityGroups/delete"
      resource_type = "microsoft.network/networksecuritygroups"
    }
    "CIS 5.2.5 - Create or Update Azure Security Solution Detected" = {
      description = "An Azure security solution has been created or updated"
      category = "Administrative"
      operation_name = "Microsoft.Security/securitySolutions/write"
      resource_type = "microsoft.security/securitySolutions"
    }
    "CIS 5.2.6 - Delete Azure Security Solution Detected" = {
      description = "An Azure security solution has been deleted"
      category = "Administrative"
      operation_name = "Microsoft.Security/securitySolutions/delete"
      resource_type = "microsoft.security/securitySolutions"
    }
    "CIS 5.2.7 - Create or Update Azure SQL Server Firewall Rule Detected" = {
      description = "An Azure SQL Server firewall rule has been created or updated"
      category = "Administrative"
      operation_name = "Microsoft.Sql/servers/firewallRules/write"
      resource_type = "microsoft.sql/servers/firewallRules"
    }
    "CIS 5.2.8 - Delete Azure SQL Server Firewall Rule Detected" = {
      description = "An Azure SQL Server firewall rule has been deleted"
      category = "Administrative"
      operation_name = "Microsoft.Security/securitySolutions/delete"
      resource_type = "microsoft.security/securitysolutions"
    }
    "CIS 5.2.9 - Create or Update Public IP Address Detected" = {
      description = "A public IP address has been created or updated"
      category = "Administrative"
      operation_name = "Microsoft.Network/publicIPAddresses/write"
      resource_type = "Microsoft.network/publicIPAddresses"
    }
    "CIS 5.2.10 - Deletion of a Public IP Address Detected" = {
      description = "A public IP address has been deleted"
      category = "Administrative"
      operation_name = "Microsoft.Network/publicIPAddresses/delete"
      resource_type = "Microsoft.network/publicIPAddresses"
    }
  }
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert
resource "azurerm_monitor_activity_log_alert" "cis_alerts" {
  for_each = local.cis_mertics
  name = each.key
  description = each.value.description
  resource_group_name = azurerm_resource_group.vf_core_resources_rg.name
  scopes = [data.azurerm_subscription.current.id]
  criteria {
    category = each.value.category
    operation_name = each.value.operation_name
    resource_type = each.value.resource_type
  }
  dynamic "action" {
    for_each = try(tolist(azurerm_monitor_action_group.vf_core_security-notifications[0].id), [])
    content {
      action_group_id = action.key
    }
  }
}
