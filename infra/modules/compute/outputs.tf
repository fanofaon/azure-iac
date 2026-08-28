output "vm_id" {
  description = "Identifiant de la machine virtuelle"
  value       = azurerm_linux_virtual_machine.this.id
}

output "vm_name" {
  description = "Nom de la machine virtuelle"
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "Adresse IP privee de la machine"
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  description = "Adresse IP publique de la machine"
  value       = azurerm_public_ip.this.ip_address
}
