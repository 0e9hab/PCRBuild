#https://confluence.tools.aws.vodafone.com/display/CSAR/Microsoft+Entra+ID+Tenant+and+Azure+Subscription+Deployment+Blueprint#MicrosoftEntraIDTenantandAzureSubscriptionDeploymentBlueprint-CostControlConfiguration
/*
Section: 7.9.1. Cost Management Budgets
*/
  
locals {
  current_year_month = formatdate("YYYY-MM",timestamp())
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/consumption_budget_subscription
resource "azurerm_consumption_budget_subscription" "vf_core_budget" {
  name = "vf-core-budget-alert"
  subscription_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  amount = var.budget_amount
  time_grain = "Monthly"
  time_period {
    start_date = "${local.current_year_month}-01T00:00:00Z"
    end_date = timeadd("${local.current_year_month}-01T00:00:00Z", "26280h")
  }
  notification{
    enabled = true
    operator = "GreaterThanOrEqualTo"
    threshold = "75"
    contact_emails = [var.customer_budget_contact_email]
  }
  notification{
    enabled = true
    operator = "GreaterThanOrEqualTo"
    threshold = "95"
    contact_emails = [var.customer_budget_contact_email]
  }
  notification{
    enabled = true
    operator = "GreaterThanOrEqualTo"
    threshold = "99"
    contact_emails = [var.customer_budget_contact_email]
  }
}
