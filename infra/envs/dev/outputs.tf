output "environment" {
  description = "Environnement Terraform courant"
  value       = var.environment
}

output "location" {
  description = "Region Azure utilisee"
  value       = var.location
}

output "resource_prefix" {
  description = "Prefixe commun utilise pour les ressources"
  value       = local.prefix
}

output "resource_group_id" {
  description = "Identifiant du Resource Group Azure"
  value       = module.resource_group.id
}

output "resource_group_name" {
  description = "Nom du Resource Group Azure"
  value       = module.resource_group.name
}

output "vm_public_ip" {
  description = "Adresse IP publique de la VM"
  value       = module.compute.public_ip_address
}

output "vm_private_ip" {
  description = "Adresse IP privee de la VM"
  value       = module.compute.private_ip_address
}
