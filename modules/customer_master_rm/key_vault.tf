#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-KeyVaultDeployment
/*
Section: 7.2 Key Vault Configuration
*/
data "azurerm_client_config" "current" {}

locals {
  truncated_subscription_guid = substr(data.azurerm_client_config.current.subscription_id, 0,4 )
}
locals {
  key_rot_current_year_month = formatdate("YYYY-MM",timestamp())
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
resource "azurerm_key_vault" "vf_core_kv" {
  location = azurerm_resource_group.vf_core_resources_rg.location
  name = "vf-core-${var.country_code}-${local.truncated_subscription_guid}-kv-${random_string.random.result}"
  resource_group_name = azurerm_resource_group.vf_core_resources_rg.name
  sku_name = "standard"
  soft_delete_retention_days = 90
  purge_protection_enabled = true
  tenant_id = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
  network_acls {
    bypass = "AzureServices"
    default_action = "Allow"
    ip_rules = ["185.69.146.0/24","194.62.232.0/24"]
  }
  tags = var.default_tags
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy
resource "azurerm_key_vault_access_policy" "access_to_group" {
  key_vault_id = azurerm_key_vault.vf_core_kv.id
  object_id = var.object_id
  tenant_id = data.azurerm_client_config.current.tenant_id

  key_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
  ]
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
  ]
}

resource "azurerm_key_vault_access_policy" "access_to_terraform" {
  key_vault_id = azurerm_key_vault.vf_core_kv.id
  object_id = data.azurerm_client_config.current.object_id
  tenant_id = data.azurerm_client_config.current.tenant_id

  key_permissions = [
    "Get",
    "List",
    "Update",
    "Create",
    "Import",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
    "Purge",
    "GetRotationPolicy",
    "SetRotationPolicy"
  ]
  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
  ]
}

resource "azurerm_key_vault_key" "vf_core_sa_key" {
  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
  rotation_policy {
    automatic {
      time_before_expiry = "P1Y"
    }
    expire_after = "P2Y"
    notify_before_expiry = "P30D"
  }
  key_type = "RSA"
  key_size = 2048
  key_vault_id = azurerm_key_vault.vf_core_kv.id
  name = "vf-core-sa-key-${random_string.random.result}"
  not_before_date = "${local.key_rot_current_year_month}-01T00:00:00Z"
  expiration_date = timeadd("${local.key_rot_current_year_month}-01T00:00:00Z", "43800h")
  tags = var.default_tags
 depends_on = [azurerm_key_vault_access_policy.access_to_group, azurerm_key_vault_access_policy.access_to_terraform, azurerm_role_assignment.vf_core_keyvault_mgmt_keyvault_adminstrator]
}

resource "random_string" "random" {
  length = 4
  min_lower = 4
  lower = true
}
