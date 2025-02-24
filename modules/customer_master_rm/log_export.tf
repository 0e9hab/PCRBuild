#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-AuditLogArchivingConfiguration
/*
Section: 7.5.1. Azure Active Directory Audit Logs Export Configuration
*/

data "azurerm_subscription" "current" {}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting
resource "azurerm_monitor_diagnostic_setting" "vf_core_audit_logs_activity" {
  name = "vf-core-audit-logs-activity"
  target_resource_id = data.azurerm_subscription.current.id
  storage_account_id = azurerm_storage_account.vfcoreaudit.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.vf_core_log_analytics.id
  enabled_log {
    category = "Administrative"
  }
  enabled_log {
    category = "Security"
  }
  enabled_log {
    category = "Policy"
  }
}

resource "azurerm_monitor_diagnostic_setting" "vf_core_audit_logs_keyvault" {
  name = "vf-core-audit-logs-keyvault"
  target_resource_id = azurerm_key_vault.vf_core_kv.id
  storage_account_id = azurerm_storage_account.vfcoreaudit.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.vf_core_log_analytics.id
  enabled_log {
    category = "AuditEvent"
  }
}
