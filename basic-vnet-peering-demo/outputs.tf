# Placeholder for outputs
output "resource_group_sea_name" {
  value = azurerm_resource_group.rg_sea.name
}

output "resource_group_eastasia_name" {
  value = azurerm_resource_group.rg_eastasia.name
}

output "vm_sea_private_ip" {
  value = azurerm_network_interface.nic_sea.private_ip_address
}

output "vm_eastasia_private_ip" {
  value = azurerm_network_interface.nic_eastasia.private_ip_address
}

output "vm_sea_id" {
  value = azurerm_linux_virtual_machine.vm_sea.id
}

output "vm_eastasia_id" {
  value = azurerm_linux_virtual_machine.vm_eastasia.id
}

output "vnet_sea_id" {
  value = azurerm_virtual_network.vnet_sea.id
}

output "vnet_eastasia_id" {
  value = azurerm_virtual_network.vnet_eastasia.id
}
