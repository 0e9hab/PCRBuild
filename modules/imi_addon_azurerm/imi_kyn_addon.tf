//Last modified 30/05/2022
#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Azure+IMI+Deployment+Blueprint
locals {
  kyn_group_map = var.imi_addon == true ? var.kyn_group_map : {}
}

data "azurerm_subscription" "current" {}

data "azuread_group" "kyn_group" {
  for_each = local.kyn_group_map
  display_name = each.value.name
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "kyn_group" {
  for_each = local.kyn_group_map
  scope                = data.azurerm_subscription.current.id
  role_definition_name = each.value.role_definition_name
  principal_id         = data.azuread_group.kyn_group[each.key].object_id
}

resource "azurerm_role_assignment" "kyn_group_owner" {
  count = var.imi_addon == true ? 1 : 0
  principal_id = data.azuread_group.kyn_group["kyn-core-administrator"].object_id
  scope        = data.azurerm_subscription.current.id
  role_definition_name = "Owner"
}
