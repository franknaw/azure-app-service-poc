variable "location" {
  description = "Azure location to deploy resources"
  type        = string
}

variable "plan_os_type" {
  description = "Service plan OS type"
  type        = string
}

variable "plan_sku_name" {
  description = "Service plan SKU name"
  type        = string
}

variable "web_app_name" {
  description = "Base app name"
  type        = string
}

variable "slot_1_name" {
  description = "Slot One name"
  type        = string
}

variable "repo_url_slot_0" {
  description = "Slot Zero Repo"
  type        = string
}

variable "branch_slot_0" {
  description = "Slot Zero Branch"
  type        = string
}


variable "repo_url_slot_1" {
  description = "Slot One Repo"
  type        = string
}

variable "branch_slot_1" {
  description = "Slot One Branch"
  type        = string
}

variable "resource_group_type" {
  description = "Service plan SKU name"
  type        = string
}

variable "product_name" {
  description = "Service plan SKU name"
  type        = string
}

variable "environment" {
  description = "Service plan SKU name"
  type        = string
}

variable "service_plan_name_prefix" {
  description = "Service plan name"
  type        = string
}

variable "function_app_name" {
  description = "Base app name"
  type        = string
}