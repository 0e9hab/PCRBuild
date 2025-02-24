#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-StorageAccountDeploymentandConfiguration
/* Section: 7.3.1. Storage Account Creation
*/
  
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "vfcoreaudit" {
  account_replication_type = lower(var.country_code) == "it" || lower(var.country_code) == "al"? "LRS" : "RAGRS"
  account_tier = "Standard"
  location = azurerm_resource_group.vf_core_resources_rg.location
  name = lower("vfcoreaudit${var.country_code}${local.truncated_subscription_guid}")
  resource_group_name = azurerm_resource_group.vf_core_resources_rg.name
  enable_https_traffic_only = true
  min_tls_version = "TLS1_2"
  allowed_copy_scope = "AAD"
  account_kind = "StorageV2"
  cross_tenant_replication_enabled = false
  infrastructure_encryption_enabled = true
  queue_encryption_key_type = "Account"
  table_encryption_key_type = "Account"
  access_tier = "Cool"
  network_rules {
    default_action = "Deny"
    ip_rules = ["185.69.146.0/24","194.62.232.0/24"]
    bypass = ["AzureServices"]
  }
  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.managed_identity_sa.id]
  }
  customer_managed_key {
    key_vault_key_id          = azurerm_key_vault_key.vf_core_sa_key.id
    user_assigned_identity_id = azurerm_user_assigned_identity.managed_identity_sa.id
  }
  
  lifecycle {
    prevent_destroy = false
    //ignore_changes = [name]
  }
  blob_properties {
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }
  tags = var.default_tags
  depends_on = [azurerm_key_vault_key.vf_core_sa_key]
}
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy
resource "azurerm_storage_management_policy" "vf_core_activity_logs_older_than_365_days" {
  storage_account_id = azurerm_storage_account.vfcoreaudit.id
  rule {
    enabled = true
    name = "vf-core-activity-logs-older-than-365-days"
    filters {
      blob_types = [
        "appendBlob"
      ]
    }
    actions {
      base_blob {
        delete_after_days_since_modification_greater_than = 365
      }
    }
  }
  depends_on = [azurerm_storage_account.vfcoreaudit]
}
