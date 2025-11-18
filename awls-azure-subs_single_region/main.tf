###########################################################
# Terraform Required Providers
###########################################################
terraform {
  required_version = ">= 0.13"

  required_providers {
    lacework = {
      source  = "lacework/lacework"
    }
  }
}

###########################################################
# Lacework Provider
###########################################################
provider "lacework" {
  account    = var.lacework_account
  api_key    = var.lacework_api_key
  api_secret = var.lacework_api_secret
}

###########################################################
# Lacework Agentless Scanning Module
###########################################################
module "lacework_agentless_scanning_canadacentral" {
  source = "lacework/agentless-scanning/azure"

  integration_level              = "SUBSCRIPTION"
  global                         = true
  create_log_analytics_workspace = true
  region                         = var.region

  scanning_subscription_id = var.azure_subscription_id
  tenant_id                = var.azure_tenant_id

  included_subscriptions = [
    "/subscriptions/${var.azure_subscription_id}"
  ]
}
