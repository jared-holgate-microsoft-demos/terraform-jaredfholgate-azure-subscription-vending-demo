locals {
    name_postfix = "${var.subscription_business_unit}-${var.subscription_purpose}"
    subscription_number_padded = format("%03s", var.subscription_number)
    subscription_name = "${local.name_postfix}-${var.subscription_number_padded}"
}

terraform {
    required_providers {
        azurerm = {
        source  = "hashicorp/azurerm"
        version = ">= 3.57.0"
        }
        azuread = {
            source = "hashicorp/azuread"
            version = ">= 2.39.0"
        }
    }
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.2.0"
  suffix = [ local.name_postfix ]
  unique-seed = local.subscription_number_padded
}


data "azuread_client_config" "current" {}

resource "azuread_application" "vending" {
  display_name = "sp-${local.name-postfix}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "vending" {
  application_id               = azuread_application.vending.application_id
}


data "azurerm_billing_enrollment_account_scope" "vending" {
  billing_account_name    = var.billing_account_name
  enrollment_account_name = var.billing_enrollment_name
}

data "azuread_users" "users" {
  user_principal_names = var.subscription_owners
}

locals {
  subscription_owners = { for user in data.azuread_users.users : user.object_id => {
        principal_id   = user.object_id
        definition     = "Owner"
        relative_scope = ""
    } 
  }
}

module "lz_vending" {
  source  = "Azure/lz-vending/azurerm"
  version = "3.2.0"

  # Set the default location for resources
  location = var.location

  # subscription variables
  subscription_alias_enabled = true
  subscription_billing_scope = data.azurerm_billing_enrollment_account_scope.vending.id
  subscription_display_name  = local.subscription_name
  subscription_alias_name    = local.subscription_name
  subscription_workload      = var.subscription_offer

  # management group association variables
  subscription_management_group_association_enabled = true
  subscription_management_group_id                  = var.management_group_id

  # role assignments
  role_assignment_enabled = true
  role_assignments = merge(local.subscription_owners, {
    owner_sp_sub = {
      principal_id   = azuread_service_principal.vending.object_id
      definition     = "Owner"
      relative_scope = ""
    }
  })
}