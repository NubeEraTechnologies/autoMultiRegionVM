terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "bd65aea3-75fe-4024-8c52-185c16367c34"
}

locals {
  vm_count = length(var.vm_regions)
}

resource "azurerm_resource_group" "rg" {
  for_each = toset(var.vm_regions)
  name     = "rg-${each.key}"
  location = each.key
}

resource "azurerm_network_interface" "nic" {
  for_each            = toset(var.vm_regions)
  name                = "nic-${each.key}"
  location            = each.key
  resource_group_name = azurerm_resource_group.rg[each.key].name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet[each.key].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_network" "vnet" {
  for_each = toset(var.vm_regions)
  name     = "vnet-${each.key}"
  address_space = ["10.${index(var.vm_regions, each.key)}.0.0/16"]
  location            = each.key
  resource_group_name = azurerm_resource_group.rg[each.key].name
}

resource "azurerm_subnet" "subnet" {
  for_each = toset(var.vm_regions)
  name                 = "subnet-${each.key}"
  resource_group_name  = azurerm_resource_group.rg[each.key].name
  virtual_network_name = azurerm_virtual_network.vnet[each.key].name
  address_prefixes     = ["10.${index(var.vm_regions, each.key)}.1.0/24"]
}

resource "azurerm_linux_virtual_machine" "vm" {
  for_each            = toset(var.vm_regions)
  name                = "vm-${each.key}"
  location            = each.key
  resource_group_name = azurerm_resource_group.rg[each.key].name
  size                = var.vm_size
  admin_username      = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("./id_rsa.pub")  # replace or create file
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
