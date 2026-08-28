variable "resource_group_name" {
  description = "Nom du Resource Group"
  type        = string
}

variable "location" {
  description = "Region Azure"
  type        = string
}

variable "nsg_name" {
  description = "Nom du Network Security Group"
  type        = string
}

variable "subnet_id" {
  description = "Identifiant du subnet auquel associer le NSG"
  type        = string
}

variable "admin_cidr" {
  description = "Adresse IP autorisee pour SSH, au format CIDR /32"
  type        = string
}

variable "tags" {
  description = "Tags Azure"
  type        = map(string)
  default     = {}
}
