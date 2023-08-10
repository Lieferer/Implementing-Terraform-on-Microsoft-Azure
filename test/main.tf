terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
  }
}

#############################################################################
# VARIABLES
#############################################################################

variable "resource_group_name" {
  type = string
}

variable "naming_prefix" {
  type    = string
  default = "itma"
}

variable "location" {
  type    = string
  default = "germanywestcentral"
}

variable "network_state" {
  type        = map(string)
  description = "map of network state properties, should include sa, cn, key, and sts"
}

variable "vm_count" {
  type    = number
  default = 2
}

locals {
  prefix = "${terraform.workspace}-${var.naming_prefix}"
}

#############################################################################
# PROVIDERS
#############################################################################

provider "azurerm" {
  features {}
}

#############################################################################
# DATA
#############################################################################

data "azurerm_subscriptions" "current" {}

data "terraform_remote_state" "networking" {
  backend   = "azurerm"
  workspace = terraform.workspace
  config = {
    storage_account_name = var.network_state["sa"]
    container_name       = var.network_state["cn"]
    key                  = var.network_state["key"]
    sas_token            = var.network_state["sts"]
  }
}

output "all" {
  value = data.terraform_remote_state.networking.outputs[*]
}

output "subscription" {
  value = data.azurerm_subscriptions.current.subscriptions
}