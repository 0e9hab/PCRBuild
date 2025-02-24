//Last modified 30/05/2022
#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Azure+IMI+Deployment+Blueprint
locals {
  kyn_user_role = var.imi_addon == true ? ["User Administrator", "Application Developer"] : []
  kyn_group_map = var.imi_addon == true ? var.kyn_group_map : {}
}

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/invitation
resource "azuread_invitation" "kyn_user" {
  count = var.imi_addon == true ? 1 : 0
  user_display_name = split("@",var.guestuseremail)[0]
  user_email_address = var.guestuseremail
  redirect_url       = "https://portal.azure.com"
}

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group
resource "azuread_group" "kyn_group" {
  for_each = local.kyn_group_map
  display_name = each.value.name
  description = each.value.description
  owners = each.value.owners == "kyn_user" ? [azuread_invitation.kyn_user[0].user_id] : []
  members = each.value.members == "kyn_user" ? [azuread_invitation.kyn_user[0].user_id] : []
  security_enabled = true
}

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role
resource "azuread_directory_role" "kyn_user_roles" {
  for_each = toset(local.kyn_user_role)
  display_name = each.value
}

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_member
resource "azuread_directory_role_member" "kyn_user" {
  for_each = toset(local.kyn_user_role)
  role_object_id   = azuread_directory_role.kyn_user_roles[each.key].object_id
  member_object_id = azuread_invitation.kyn_user[0].user_id
}
