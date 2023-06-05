variable "tfe_token" {
  type        = string
  description = "The Terraform Cloud API token"
  sensitive   = true
}

variable "terraform_organisation" {
  type        = string
  description = "The Terraform Cloud Organisation"
  default     = "jared-holgate-microsoft"
}

variable "oauth_token_id" {
  type        = string
  description = "The OAuth token ID"
  sensitive   = true
}

variable "module_repository" {
  type        = string
  description = "The GitHub repository for the module"
  default     = "jared-holgate-microsoft-demos/terraform-jaredfholgate-azure-subscription-vending-demo"
}

terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = ">= 0.44.1"
    }
  }
}

provider "tfe" {
  token        = var.tfe_token
  organization = var.terraform_organisation
}

resource "tfe_registry_module" "registry_module" {
  vcs_repo {
    display_identifier = var.module_repository
    identifier         = var.module_repository
    oauth_token_id     = var.oauth_token_id
  }
  no_code = true
}

resource "tfe_no_code_module" "registry_module" {
  registry_module = tfe_registry_module.registry_module.id

  variable_options {
    name    = "billing_account_name"
    type    = "string"
    options = ["7690848", "example 2", "example 3"]
  }

  variable_options {
    name    = "billing_enrollment_name"
    type    = "string"
    options = ["340368", "example 2", "example 3"]
  }

  variable_options {
    name    = "subscription_business_unit"
    type    = "string"
    options = ["cps", "mkting", "prdn"]
  }

  variable_options {
    name    = "subscription_purpose"
    type    = "string"
    options = ["sandbox", "dev", "test", "prod"]
  }

  variable_options {
    name    = "location"
    type    = "string"
    options = ["uksouth", "northeurope", "westeurope"]
  }

  variable_options {
    name    = "subscription_management_group"
    type    = "string"
    options = ["Subscription Vending Demo", "Tenant Root Group", "example 3"]
  }

  variable_options {
    name    = "subscription_offer"
    type    = "string"
    options = ["DevTest", "Production"]
  }

}