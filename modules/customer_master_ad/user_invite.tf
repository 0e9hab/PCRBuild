#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-EntraIDUserAccounts

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/invitation
resource "azuread_invitation" "L2_primary_user" {
  count = var.vodafone_support_primary_L2_username == "" ? 0 : 1
  user_display_name = var.vodafone_support_primary_L2_username
  user_email_address = var.vodafone_support_primary_L2_useremail
  redirect_url       = "https://portal.azure.com"
  message {
    body                  = "Hello there! You are invited to join my Azure tenant!!"
  }
}

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group_member
resource "azuread_group_member" "L2_primary_user" {
  count = var.vodafone_support_primary_L2_username == "" ? 0 : 1
  group_object_id  = try(azuread_group.vf-core-subscription-level2-support[count.index].id, null)
  member_object_id = try(azuread_invitation.L2_primary_user[count.index].user_id, null)
}

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role
resource "azuread_directory_role" "L2_primary_user" {
  count = var.vodafone_support_primary_L2_username == "" ? 0 : 1
  display_name = "User Administrator"
}

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/directory_role_member
resource "azuread_directory_role_assignment" "L2_primary_user" {
  count = var.vodafone_support_primary_L2_username == "" ? 0 : 1
  role_id   = try(azuread_directory_role.L2_primary_user[count.index].object_id, null)
  principal_object_id = try(azuread_invitation.L2_primary_user[count.index].user_id, null)
}

