variable "resource_group_name" {
  description = "Nom du Resource Group"
  type        = string
}

variable "location" {
  description = "Region Azure"
  type        = string
}

variable "subnet_id" {
  description = "Identifiant du subnet"
  type        = string
}

variable "vm_name" {
  description = "Nom de la machine virtuelle"
  type        = string
}

variable "admin_username" {
  description = "Utilisateur administrateur de la VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Cle publique SSH utilisee pour la VM"
  type        = string
}

variable "vm_size" {
  description = "Taille de la machine virtuelle"
  type        = string
  default     = "Standard_B2s"
}

variable "tags" {
  description = "Tags Azure"
  type        = map(string)
  default     = {}
}
