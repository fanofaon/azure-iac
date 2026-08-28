output "nsg_id" {
  description = "Identifiant du Network Security Group"
  value       = azurerm_network_security_group.this.id
}

output "nsg_name" {
  description = "Nom du Network Security Group"
  value       = azurerm_network_security_group.this.name
}
