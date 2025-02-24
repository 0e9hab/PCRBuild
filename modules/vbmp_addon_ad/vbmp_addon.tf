//Last modified 30/05/2022
#https://confluence.tools.aws.vodafone.com/display/CSAR/Azure+Tenant+and+Subscription+Deployment+Blueprint#AzureTenantandSubscriptionDeploymentBlueprint-AzureActiveDirectoryGroups
/*
Section: 5.1.1. Azure Active Directory Service Principal
*/

data "azuread_user" "admin_user" {
  user_principal_name = "admin@${var.company_name}.onmicrosoft.com"
}

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal
resource "azuread_service_principal" "vf_core_svc_vbmp_em_service_principal" {
  count = var.vbmp_addon ? 1:0
  application_id = azuread_application.vf_core_svc_vbmp_em_service_principal_application[count.index].application_id
}

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password
resource "azuread_application_password" "vbmp_client_secret" {
  count = var.vbmp_addon ? 1:0
  application_object_id = azuread_application.vf_core_svc_vbmp_em_service_principal_application[count.index].object_id
  end_date_relative = "17520h"
  lifecycle {
    ignore_changes = [end_date_relative]
  }
  depends_on = [azuread_service_principal.vf_core_svc_vbmp_em_service_principal, azuread_application.vf_core_svc_vbmp_em_service_principal_application]
}

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application
resource "azuread_application" "vf_core_svc_vbmp_em_service_principal_application" {
  count = var.vbmp_addon ? 1:0
  display_name = "vf-core-svc-vbmp-${var.country_code}-em-service-principal"
  /*sign_in_audience = "AzureADMyOrg"
  implicit_grant {
    access_token_issuance_enabled = true
  }*/
  //oauth2_allow_implicit_flow = true
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    resource_access {
      id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }

  required_resource_access {
    resource_app_id = "00000002-0000-0000-c000-000000000000"
    //Directory.AccessAsUser.All
    resource_access {
      id = "a42657d6-7f20-40e3-b6f0-cee03008a62a"
      type = "Scope"
    }

    //Directory.Read.All
    resource_access {
      id = "5778995a-e1bf-45b8-affa-663a9f3f4d04"
      type = "Scope"
    }

    //Directory.ReadWrite.All
    resource_access {
      id = "78c8a3c8-a07e-4b9e-af1b-b5ccab50a175"
      type = "Scope"
    }

    //User.Read
    resource_access {
      id = "311a71cc-e848-46a1-bdf8-97ff7156d8e6"
      type = "Scope"
    }

    //Directory.Read.All
    resource_access {
      id = "5778995a-e1bf-45b8-affa-663a9f3f4d04"
      type = "Role"
    }

    //Directory.ReadWrite.All
    resource_access {
      id = "78c8a3c8-a07e-4b9e-af1b-b5ccab50a175"
      type = "Role"
    }
  }


  required_resource_access {
    resource_app_id = "797f4846-ba00-4fd7-ba43-dac1f8f63013"
    resource_access {
      id = "41094075-9dad-400e-a0bd-54e686782033"
      type = "Scope"
    }
  }
}

#https://confluence.tools.aws.vodafone.com/display/CSAR/Azure+Tenant+and+Subscription+Deployment+Blueprint#AzureTenantandSubscriptionDeploymentBlueprint-AzureActiveDirectoryUsers
/*
Section: 5.1.2. Azure Active Directory Groups
*/

#https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group
resource "azuread_group" "vf_corevbmpprovider" {
  count = var.vbmp_addon ? 1:0
  display_name = "vf-core-vbmp-provider"
  description = "Allows the Vodafone Business MultiCloud Platform to deploy resources on behalf of the customer"
  owners = [data.azuread_user.admin_user.object_id]
  members = [azuread_service_principal.vf_core_svc_vbmp_em_service_principal[count.index].object_id]
  security_enabled = true
}

output "vf_corevbmpprovider_object_id" {
  value = var.vbmp_addon ? azuread_group.vf_corevbmpprovider[0].object_id : ""
}

output "vbmp_service_principal_name" {
  value = var.vbmp_addon ? azuread_application.vf_core_svc_vbmp_em_service_principal_application[0].display_name : "VBMP Addon not enabled"
}
output "vbmp_client_secret" {
  value = var.vbmp_addon ? azuread_application_password.vbmp_client_secret[0].value : "VBMP Addon not enabled"
}
