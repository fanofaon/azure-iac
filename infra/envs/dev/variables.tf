variable "project_name" {
  description = "Nom du projet"
  type        = string
}

variable "environment" {
  description = "Environnement cible"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "prod"], var.environment)
    error_message = "Valeurs autorisees : dev, test ou prod."
  }
}

variable "location" {
  description = "Region Azure utilisee"
  type        = string
  default     = "francecentral"
}

variable "admin_cidr" {
  description = "Adresse IP autorisee pour SSH, au format CIDR /32"
  type        = string
}

variable "admin_username" {
  description = "Utilisateur administrateur de la VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Chemin vers la cle publique SSH"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "vm_size" {
  description = "Taille de la VM Azure"
  type        = string
  default     = "Standard_B2s"
}
