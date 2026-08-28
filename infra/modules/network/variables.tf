variable "resource_group_name" {
  description = "Nom du Resource Group"
  type        = string
}

variable "location" {
  description = "Region Azure"
  type        = string
}

variable "vnet_name" {
  description = "Nom du Virtual Network"
  type        = string
}

variable "address_space" {
  description = "Plage CIDR du Virtual Network"
  type        = list(string)
}

variable "subnet_name" {
  description = "Nom du sous-reseau"
  type        = string
}

variable "subnet_prefixes" {
  description = "Plage CIDR du sous-reseau"
  type        = list(string)
}

variable "tags" {
  description = "Tags Azure"
  type        = map(string)
  default     = {}
}
