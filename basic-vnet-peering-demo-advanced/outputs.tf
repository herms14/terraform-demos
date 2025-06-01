# Resource group names
output "resource_group_names" {
  value = {
    for key, rg in azurerm_resource_group.rg : key => rg.name
  }
}

# VM private IPs
output "vm_private_ips" {
  value = {
    for key, nic in azurerm_network_interface.nic : key => nic.private_ip_address
  }
}

# VM IDs
output "vm_ids" {
  value = {
    for key, vm in azurerm_linux_virtual_machine.vm : key => vm.id
  }
}

# Virtual Network IDs
output "vnet_ids" {
  value = {
    for key, vnet in azurerm_virtual_network.vnet : key => vnet.id
  }
}
