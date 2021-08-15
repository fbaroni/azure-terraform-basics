provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "terraform-basics" {
  name     = "terraform-basics"
  location = "${var.location}"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "terraform-basics" {
  name                = "terraform-basics"
  resource_group_name = azurerm_resource_group.terraform-basics.name
  location            = azurerm_resource_group.terraform-basics.location
  address_space       = ["10.0.0.0/16"]
}


resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.terraform-basics.name
  virtual_network_name = azurerm_virtual_network.terraform-basics.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "terraform-basics" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.terraform-basics.location
  resource_group_name = azurerm_resource_group.terraform-basics.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.terraform-basics.location
  resource_group_name   = azurerm_resource_group.terraform-basics.name
  network_interface_ids = [azurerm_network_interface.terraform-basics.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "testing"
  }
}