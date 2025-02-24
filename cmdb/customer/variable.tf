variable "customer_client_id" {
  default = ""
}

variable "customer_client_secret" {
  default = ""
}

variable "customer_tenant_id" {
  default = ""
}

variable "customer_subscription_id" {
  default = ""
}

variable "company_name" {
  default = ""
}

variable "customer_subscription_owner_firstname" {
  default = ""
}

variable "customer_subscription_owner_lastname" {
  default = ""
}

variable "customer_subscription_contributor_firstname" {
  default = ""
}

variable "customer_subscription_contributor_lastname" {
  default = ""
}

variable "vodafone_support_primary_L2_username" {
  default = ""
}

variable "vodafone_support_primary_L2_useremail" {
  default = ""
}

variable "regional_tooling_accounts" {
  default = {
    gb-official = {
      location = "UK South"
      country_specific_security_policies = {
        "CIS Microsoft Azure Foundations Benchmark 2.0.0" = {
          id = "/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e"
        }
      }
    }
    gb-commercial = {
      location = "UK South"
      country_specific_security_policies = {
        "CIS Microsoft Azure Foundations Benchmark 2.0.0" = {
          id = "/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e"
          maximumDaysToRotate=365
        }
      }
    }
    it-commercial = {
      location = "Italy North"
      country_specific_security_policies = {
        "CIS Microsoft Azure Foundations Benchmark 2.0.0" = {
          id = "/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e"
        }
      }
    }
    ie-commercial = {
      location = "North Europe"
      country_specific_security_policies = {
        "CIS Microsoft Azure Foundations Benchmark 2.0.0" = {
          id = "/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e"
        }
      }
    }
    es-commercial = {
      location = "West Europe"
      country_specific_security_policies = {
        "CIS Microsoft Azure Foundations Benchmark 2.0.0" = {
          id = "/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e"
        }
      }
    }
    pt-commercial = {
      location = "West Europe"
      country_specific_security_policies = {
        "CIS Microsoft Azure Foundations Benchmark 2.0.0" = {
          id = "/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e"
        }
      }
    }
    al-commercial = {
      location = "Italy North"
      country_specific_security_policies = {
        "CIS Microsoft Azure Foundations Benchmark 2.0.0" = {
          id = "/providers/Microsoft.Authorization/policySetDefinitions/06f19060-9e68-4070-92ca-f15cc126059e"
        }
      }
    }
  }
}

variable "country_code" {
  default = ""
}

variable "is_uk_official" {
  default = ""
}

variable "customer_security_contact_email" {
  default = ""
}

variable "customer_budget_contact_email" {
  default = ""
}

variable "customer_service_health_contact_email" {
  default = ""
}

variable "budget_amount" {
  default = ""
}

variable "default_tags" {
  default = {
    DeployedBy = "Vodafone"
    VodafoneBuildVersion = "1.0"
    VodafoneProduct = "PCR-Core"
  }
}

variable "imi_addon" {
  default = false
  type = bool
}

variable "vbmp_addon" {
  default = false
  type = bool
}
