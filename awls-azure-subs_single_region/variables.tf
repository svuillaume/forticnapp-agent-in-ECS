###########################################################
# Lacework Credentials
###########################################################
variable "lacework_account" {
  type        = string
  description = "The name of the Lacework account."
}

variable "lacework_api_key" {
  type        = string
  sensitive   = true
  description = "Lacework API key for authentication."
}

variable "lacework_api_secret" {
  type        = string
  sensitive   = true
  description = "Lacework API secret for authentication."
}

###########################################################
# Azure Configuration
###########################################################
variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID where scanner is deployed."
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure tenant ID where scanner is deployed."
}

variable "region" {
  type        = string
  description = "Azure region to deploy Lacework scanner."
}
