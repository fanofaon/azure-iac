output "id" {
  description = "Identifiant du Resource Group"
  value       = azurerm_resource_group.this.id
}

output "name" {
  description = "Nom du Resource Group"
  value       = azurerm_resource_group.this.name
}

output "location" {
  description = "Region du Resource Group"
  value       = azurerm_resource_group.this.location
}
