#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint
provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "cae-mgmt-pcr-tfstate-manager"
    key = "terraform/azure/cae-mgmt-pcr-tfstate-manager/state/terraform.tfstate"
    region = "eu-west-2"
    dynamodb_table = "cae-mgmt-pcr-tfstate-locks"
    kms_key_id = "arn:aws:kms:eu-west-2:339070303227:key/a7f8217c-62ac-4dc4-9859-92af2cee0eec"
    encrypt = true
  }

  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "=3.78.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "=2.45.0"
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
  skip_provider_registration = true
  subscription_id = var.customer_subscription_id
  client_id = var.customer_client_id
  client_secret = var.customer_client_secret
  tenant_id = var.customer_tenant_id
}

locals {
  is_uk_official = var.country_code
  country_code = substr(var.country_code, 0, 2)
  location = lookup(lookup(var.regional_tooling_accounts, lower(var.country_code), ""), "location", "")
  security_policies = lookup(lookup(var.regional_tooling_accounts, lower(var.country_code), ""), "country_specific_security_policies", {})
}

module "customer_master_ad" {
  source = "../../modules/customer_master_ad"
  company_name = var.company_name
  location = local.location
  country_code = local.country_code
  customer_subscription_owner_firstname = var.customer_subscription_owner_firstname
  customer_subscription_owner_lastname = var.customer_subscription_owner_lastname
  customer_subscription_contributor_firstname = var.customer_subscription_contributor_firstname
  customer_subscription_contributor_lastname = var.customer_subscription_contributor_lastname
  vodafone_support_primary_L2_username = var.vodafone_support_primary_L2_username
  vodafone_support_primary_L2_useremail = var.vodafone_support_primary_L2_useremail
}

module "customer_master_rm" {
  source = "../../modules/customer_master_rm"
  country_code = local.country_code
  location = local.location
  company_name = var.company_name
  object_id = module.customer_master_ad.object_id
  customer_security_contact_email = var.customer_security_contact_email
  customer_budget_contact_email = var.customer_budget_contact_email
  customer_service_health_contact_email = var.customer_service_health_contact_email
  budget_amount = var.budget_amount
  security_policies = local.security_policies
  default_tags = var.default_tags
  is_uk_official = local.is_uk_official
  depends_on = [module.customer_master_ad]
}

module "customer_master_resource_lock" {
  source = "../../modules/resource_lock"
  resource_id = module.customer_master_rm.resource_id
  depends_on = [module.customer_master_rm]
}

//Subscription member details
output "customer_subscription_owner_username" {
  value = module.customer_master_ad.customer_subscription_owner_username
}
output "customer_subscription_owner_email" {
  value = module.customer_master_ad.customer_subscription_owner_email
}
output "customer_subscription_owner_password" {
  value = module.customer_master_ad.customer_subscription_owner_password
}

output "customer_subscription_contributor_username" {
  value = module.customer_master_ad.customer_subscription_contributor_username
}
output "customer_subscription_contributor_email" {
  value = module.customer_master_ad.customer_subscription_contributor_email
}
output "customer_subscription_contributor_password" {
  value = module.customer_master_ad.customer_subscription_contributor_password
}
