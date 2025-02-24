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

variable "country_code" {
  default = ""
}

variable "default_tags" {
  default = {
    DeployedBy = "Vodafone"
    VodafoneBuildVersion = "1.0"
    VodafoneProduct = "PCR-Core"
  }
}

variable "vbmp_addon" {
  default = false
  type = bool
}

variable "imi_uk_official_addon" {
  default = false
  type = bool
}

variable "imi_commercial_addon" {
  default = false
  type = bool
}

variable "kyn_group_map" {
  default = {
    kyn-core-administrator = {
      name                 = "kyn-core-administrator"
      description          = "Provides group members with the subscription owner and user access administrator roles"
      owners               = "kyn_user"
      members              = "kyn_user"
      role_definition_name = "User Access Administrator"
    }
    kyn-core-power-user = {
      name                 = "kyn-core-power-user"
      description          = "Provides group members with the subscription contributor role"
      owners               = "kyn_user"
      members              = ""
      role_definition_name = "Contributor"
    }
    kyn-core-iam-admin = {
      name                 = "kyn-core-iam-admin"
      description          = "Provides group members with the subscription user access administrator role"
      owners               = "kyn_user"
      members              = ""
      role_definition_name = "User Access Administrator"
    }
    kyn-core-read-only = {
      name                 = "kyn-core-read-only"
      description          = "Provides group members with the subscription reader role"
      owners               = "kyn_user"
      members              = ""
      role_definition_name = "Reader"
    }
  }
}

variable "guestuseremail" {
  default = ""
}