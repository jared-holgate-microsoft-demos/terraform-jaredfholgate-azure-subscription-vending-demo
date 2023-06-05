variable "subscription_purpose" {
  type        = string
  description = "The purpose of the subscription e.g. dev, test, prod, sandbox, etc"
  validation {
    condition     = length(var.subscription_purpose) > 1 && length(var.subscription_purpose) < 10
    error_message = "The subscription_purpose must be between 2 and 10 characters"
  }
}

variable "subscription_business_unit" {
  type        = string
  description = "The business unit of the subscription e.g. hr, finance, it, etc"
  validation {
    condition     = length(var.subscription_business_unit) > 1 && length(var.subscription_business_unit) < 10
    error_message = "The subscription_business_unit must be between 2 and 10 characters"
  }
}

variable "subscription_number" {
  type        = number
  description = "The subscription number e.g. 1, 2, 3, 45, etc"
  validation {
    condition     = var.subscription_number > 0 && var.subscription_number < 100
    error_message = "The subscription_number must be between 1 and 99"
  }
}

variable "location" {
  type        = string
  description = "Default location of the resources"
  default     = "uksouth"
  validation {
    condition     = can(regex("^(uksouth|ukwest|westeurope|northeurope|eastus|westus|eastus2|westus2|southcentralus|centralus|northcentralus|japaneast|japanwest|southeastasia|australiaeast|australiasoutheast|brazilsouth|southafricanorth|canadacentral|canadaeast|francecentral|koreacentral|koreasouth|uksouth|ukwest|westcentralus|westeurope|westus|westus2)$", var.location))
    error_message = "The location must be a valid Azure region"
  }
}

variable "subscription_offer" {
  type        = string
  description = "The offer type of the subscription, can be DevTest or Production"
  validation {
    condition     = can(regex("^(DevTest|Production)$", var.subscription_offer))
    error_message = "The subscription offer must be either DevTest or Production"
  }
}

variable "subscription_description" {
  type        = string
  description = "The description of the subscriptions purpose"
}

variable "subscription_management_group" {
  type        = string
  description = "The management group name to assign the subscription to"
}

variable "billing_account_name" {
  type        = string
  description = "The name of the billing account"
}

variable "billing_enrollment_name" {
  type        = string
  description = "The name of the billing enrollment"
}

variable "create_service_principal" {
  type        = bool
  description = "Create a service principal for the subscription"
}

variable "create_repository" {
  type        = bool
  description = "Create a repository for the subscription"
}

variable "create_terraform_cloud_workspace" {
  type        = bool
  description = "Create a Terraform Cloud workspace for the subscription"
}

variable "subscription_owners" {
  type        = list(string)
  description = "The spns of the owners of the subscription"
}