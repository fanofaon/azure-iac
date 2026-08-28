output "vnet_id" {
  description = "Identifiant du Virtual Network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Nom du Virtual Network"
  value       = azurerm_virtual_network.this.name
}

output "subnet_id" {
  description = "Identifiant du subnet"
  value       = azurerm_subnet.this.id
}

output "subnet_name" {
  description = "Nom du subnet"
  value       = azurerm_subnet.this.name
}
