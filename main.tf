terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Rest of the configuration will be added below

resource "azurerm_resource_group" "rg_sea" {
  name     = "demo-1-sea-rg"
  location = "Southeast Asia"
}

resource "azurerm_resource_group" "rg_eastasia" {
  name     = "demo-2-eastasia-rg"
  location = "East Asia"
}

resource "azurerm_virtual_network" "vnet_sea" {
  name                = "demo-1-sea-vnet"
  address_space       = ["10.1.0.0/20"]
  location            = azurerm_resource_group.rg_sea.location
  resource_group_name = azurerm_resource_group.rg_sea.name
}

resource "azurerm_subnet" "subnet_sea" {
  name                 = "demo-1-sea-subnet"
  resource_group_name  = azurerm_resource_group.rg_sea.name
  virtual_network_name = azurerm_virtual_network.vnet_sea.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_virtual_network" "vnet_eastasia" {
  name                = "demo-2-eastasia-vnet"
  address_space       = ["10.2.0.0/20"]
  location            = azurerm_resource_group.rg_eastasia.location
  resource_group_name = azurerm_resource_group.rg_eastasia.name
}

resource "azurerm_subnet" "subnet_eastasia" {
  name                 = "demo-2-eastasia-subnet"
  resource_group_name  = azurerm_resource_group.rg_eastasia.name
  virtual_network_name = azurerm_virtual_network.vnet_eastasia.name
  address_prefixes     = ["10.2.1.0/24"]
}

resource "azurerm_network_interface" "nic_sea" {
  name                = "demo-1-sea-nic"
  location            = azurerm_resource_group.rg_sea.location
  resource_group_name = azurerm_resource_group.rg_sea.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_sea.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_eastasia" {
  name                = "demo-2-eastasia-nic"
  location            = azurerm_resource_group.rg_eastasia.location
  resource_group_name = azurerm_resource_group.rg_eastasia.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet_eastasia.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm_sea" {
  name                = "demo-1-sea-vm"
  resource_group_name = azurerm_resource_group.rg_sea.name
  location            = azurerm_resource_group.rg_sea.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic_sea.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

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

resource "azurerm_linux_virtual_machine" "vm_eastasia" {
  name                = "demo-2-eastasia-vm"
  resource_group_name = azurerm_resource_group.rg_eastasia.name
  location            = azurerm_resource_group.rg_eastasia.location
  size                = var.vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.nic_eastasia.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

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

resource "azurerm_virtual_network_peering" "peering_sea_to_eastasia" {
  name                      = "peer-sea-to-eastasia"
  resource_group_name       = azurerm_resource_group.rg_sea.name
  virtual_network_name      = azurerm_virtual_network.vnet_sea.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_eastasia.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "peering_eastasia_to_sea" {
  name                      = "peer-eastasia-to-sea"
  resource_group_name       = azurerm_resource_group.rg_eastasia.name
  virtual_network_name      = azurerm_virtual_network.vnet_eastasia.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_sea.id
  allow_forwarded_traffic   = true
}
