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
  environment         = var.environment
  product_name        = var.product_name
  business_unit       = "infra"
  product_group       = "fnaw"
  subscription_id     = module.subscription.output.subscription_id
  subscription_type   = "dev"
  resource_group_type = var.resource_group_type
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
Create App Service Environment (ASE)
  An ASE is a single-tenant deployment of Azure App Service that runs on your virtual network.
  Applications are hosted in App Service plans, which are created in an App Service Environment.
  An ASE is essentially a provisioning profile for an application host
  See: https://docs.microsoft.com/en-us/azure/app-service/environment/overview
  See: https://docs.microsoft.com/en-us/azure/app-service/environment/using-an-ase
*/
//resource "azurerm_app_service_environment" "ase" {
//  name                         = "franknawase"
//  resource_group_name          = module.resource_group.rg.name
//  subnet_id                    = module.vnet.subnet_public.id
//  pricing_tier                 = "I1"
//  front_end_scale_factor       = 5
//  internal_load_balancing_mode = "Web, Publishing"
//  allowed_user_ip_cidrs        = ["172.111.4.104/32"]
//
//  cluster_setting {
//    name  = "DisableTls1.0"
//    value = "1"
//  }
//}

/*
Create an app service plan.
  An App Service plan defines a set of compute resources for a web app to run.
  These compute resources are analogous to the server farm in conventional web hosting.
  One or more apps can be configured to run on the same computing resources (or in the same App Service plan).
  See: https://docs.microsoft.com/en-us/azure/app-service/overview-hosting-plans
*/
resource "azurerm_service_plan" "web_sp" {
  name                       = join("-", [var.service_plan_name_prefix, var.plan_os_type])
  location                   = var.location
  resource_group_name        = module.resource_group.rg.name
  #app_service_environment_id = azurerm_app_service_environment.ase.id
  os_type                    = var.plan_os_type
  sku_name                   = var.plan_sku_name
  tags = merge({
    Name = "${module.metadata.names.product_name}-${var.plan_os_type}-service-plan",
    },
    module.metadata.tags
  )
}

resource "azurerm_service_plan" "function_sp" {
  name                = "function-sp-${var.plan_os_type}"
  location            = var.location
  resource_group_name = module.resource_group.rg.name
  os_type             = var.plan_os_type
  sku_name            = var.plan_sku_name
  tags = merge({
    Name = "${module.metadata.names.product_name}-${var.plan_os_type}-service-plan",
    },
    module.metadata.tags
  )
}
