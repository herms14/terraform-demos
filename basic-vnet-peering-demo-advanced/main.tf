terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }

  required_version = ">= 1.3"
}

provider "azurerm" {
  features {}
}



# Resource Groups
resource "azurerm_resource_group" "rg" {
  for_each = var.regions

  name     = "demo-${each.key}-rg"
  location = each.value.location
}

# Virtual Networks
resource "azurerm_virtual_network" "vnet" {
  for_each = var.regions

  name                = "demo-${each.key}-vnet"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  address_space       = [each.value.address_space]
}

# Subnets
resource "azurerm_subnet" "subnet" {
  for_each = var.regions

  name                 = "demo-${each.key}-subnet"
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = [each.value.subnet_prefix]
}

# NICs
resource "azurerm_network_interface" "nic" {
  for_each = var.regions

  name                = "demo-${each.key}-nic"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}

# Virtual Machines with Password Auth
resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.regions

  name                = "demo-${each.key}-vm"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

# Manual Peering between SEA and EASTASIA
resource "azurerm_virtual_network_peering" "peer_sea_to_eastasia" {
  name                      = "peer-sea-to-eastasia"
  resource_group_name       = azurerm_resource_group.rg["sea"].name
  virtual_network_name      = azurerm_virtual_network.vnet["sea"].name
  remote_virtual_network_id = azurerm_virtual_network.vnet["eastasia"].id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peer_eastasia_to_sea" {
  name                      = "peer-eastasia-to-sea"
  resource_group_name       = azurerm_resource_group.rg["eastasia"].name
  virtual_network_name      = azurerm_virtual_network.vnet["eastasia"].name
  remote_virtual_network_id = azurerm_virtual_network.vnet["sea"].id
  allow_forwarded_traffic   = true
}
