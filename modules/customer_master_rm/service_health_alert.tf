#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-ServiceHealthAlertConfiguration
/*
Section: 7.8. Service Health Alert Configuration
*/
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_activity_log_alert
resource "azurerm_monitor_activity_log_alert" "vf_core_health_alert" {
  name = "vf-core-health-alert"
  resource_group_name = azurerm_resource_group.vf_core_resources_rg.name
  scopes = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  criteria {
    category = "ServiceHealth"
    service_health {
      locations = ["Global"]
    }
  }

  dynamic "action" {
    for_each = try(tolist(azurerm_monitor_action_group.vf_core_health_notifications[0].id),[])
    content {
      action_group_id = action.key
    }
  }
  tags = var.default_tags
}
