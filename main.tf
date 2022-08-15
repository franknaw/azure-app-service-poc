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

/*
Azure Subscription Data Module.
This module will return data about a specific Azure subscription.
*/
module "subscription" {
  source          = "git::https://github.com/Azure-Terraform/terraform-azurerm-subscription-data.git?ref=v1.0.0"
  subscription_id = data.azurerm_subscription.current.subscription_id
}

/*
Azure Naming Module.
This repository contains a list of variables and standards for naming resources in Microsoft Azure. It serves these primary purposes:

1. A central location for development teams to research and collaborate on allowed values and naming conventions.
2. A single source of truth for data values used in policy enforcement, billing, and naming.
3. A RESTful data source for application requiring information on approved values, variables and names.

This also show a great example of a github workflow that will deploy and run a RESTful API written in python.
*/
module "naming" {
  source = "git::https://github.com/Azure-Terraform/example-naming-template.git?ref=v1.0.0"
}

/*
Azure Metadata Module.
This module will return a map of mandatory tag for resources in Azure.

It is recommended that you always use this module to generate tags as it will prevent code duplication.
Also, it's reccommended to leverage this data as "metadata" to determine core details about resources in other modules.
*/
module "metadata" {
  source = "git::https://github.com/Azure-Terraform/terraform-azurerm-metadata.git?ref=v1.5.0"

  naming_rules = module.naming.yaml

  market              = "us"
  project             = "https://github.com/franknaw/azure-simple-app-service"
  location            = var.location
  environment         = "sandbox"
  product_name        = "appservice1"
  business_unit       = "infra"
  product_group       = "fnaw"
  subscription_id     = module.subscription.output.subscription_id
  subscription_type   = "dev"
  resource_group_type = "app"
}

/*
Azure Resource Group Module.
This module will create a new Resource Group in Azure.

Naming for this resource is as follows, based on published RBA naming convention.
*/
module "resource_group" {
  source = "git::https://github.com/Azure-Terraform/terraform-azurerm-resource-group.git?ref=v2.0.0"

  location = module.metadata.location
  names    = module.metadata.names
  tags     = module.metadata.tags
}

/*
Simple VNET Module.
*/
module "vnet" {
  source = "git::https://github.com/franknaw/azure-simple-network.git?ref=v1.0.0"

  location                 = module.resource_group.location
  resource_group_name      = module.resource_group.name
  product_name             = module.metadata.names.product_name
  tags                     = module.metadata.tags
  address_space            = ["10.12.0.0/22"]
  address_prefixes_private = ["10.12.0.0/24"]
  address_prefixes_public  = ["10.12.1.0/24"]
}

/*
Windows/Linux Web App Service
*/
module "web_app" {
  source = "git::https://github.com/franknaw/azure-simple-app-service-web-app.git?ref=v0.0.1"

  location            = module.resource_group.rg.location
  resource_group_name = module.resource_group.rg.name
  product_name        = module.metadata.names.product_name
  tags                = module.metadata.tags
  plan_os_type        = var.plan_os_type
  plan_sku_name       = var.plan_sku_name
  web_app_name        = var.web_app_name
  slot_1_name         = var.slot_1_name
  repo_url_slot_0     = var.repo_url_slot_0
  branch_slot_0       = var.branch_slot_0
  repo_url_slot_1     = var.repo_url_slot_1
  branch_slot_1       = var.branch_slot_1
}

