terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_subscription" "current" {
}

data "azurerm_resource_group" "rg" {
  name = join("-", [var.resource_group_type, var.product_name, var.environment, var.location])
}

data "azurerm_service_plan" "sp" {
  name                = join("-", [var.service_plan_name_prefix, var.plan_os_type])
  resource_group_name = join("-", [var.resource_group_type, var.product_name, var.environment, var.location])
}

/*
Windows/Linux Web App Service
*/

module "app_function" {
  source = "git::https://github.com/franknaw/azure-simple-app-service-function.git?ref=v0.0.2"

  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  product_name        = var.product_name
  tags                = {}
  plan_os_type        = var.plan_os_type
  plan_sku_name       = var.plan_sku_name
  app_name            = var.function_app_name
  slot_1_name         = var.slot_1_name
  service_plan        = data.azurerm_service_plan.sp
}
