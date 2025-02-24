//Last modified 30/05/2022
provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "cae-mgmt-pcr-tfstate-manager"
    key = "terraform/azure/cae-mgmt-pcr-tfstate-manager/state/terraform-addon.tfstate"
    region = "eu-west-2"
    dynamodb_table = "cae-mgmt-pcr-tfstate-locks"
    kms_key_id = "arn:aws:kms:eu-west-2:339070303227:key/a7f8217c-62ac-4dc4-9859-92af2cee0eec"
    encrypt = true
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=2.64.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "=2.16.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}


provider "azuread" {
  client_id = var.customer_client_id
  client_secret = var.customer_client_secret
  tenant_id = var.customer_tenant_id
}

provider "azurerm" {
  features {}
  subscription_id = var.customer_subscription_id
  client_id = var.customer_client_id
  client_secret = var.customer_client_secret
  tenant_id = var.customer_tenant_id
}

locals {
  imi_addon = var.imi_uk_official_addon || var.imi_commercial_addon
  }

module "imi_addon_ad" {
  source = "../../modules/imi_addon_azuread"
  company_name = var.company_name
  imi_addon = local.imi_addon
  kyn_group_map = var.kyn_group_map
  guestuseremail = var.guestuseremail
}

module "imi_addon_rm" {
  source = "../../modules/imi_addon_azurerm"
  imi_addon = local.imi_addon
  kyn_group_map = var.kyn_group_map
  depends_on = [module.imi_addon_ad]
}

module "vbmp_addon_ad" {
  source = "../../modules/vbmp_addon_ad"
  vbmp_addon = var.vbmp_addon
  company_name = var.company_name
}

module "vbmp_addon_rm" {
  source = "../../modules/vbmp_addon_rm"
  vbmp_addon = var.vbmp_addon
  vf_corevbmpprovider_object_id = module.vbmp_addon_ad.vf_corevbmpprovider_object_id
  depends_on = [module.vbmp_addon_ad]
}

//VBMP Service Principal Details
output "vf_corevbmpprovider_object_id" {
  value = module.vbmp_addon_ad.vf_corevbmpprovider_object_id
}
output "vbmp_service_principal_name" {
  value = module.vbmp_addon_ad.vbmp_service_principal_name
}

output "vbmp_client_secret" {
  value = module.vbmp_addon_ad.vbmp_client_secret
}
