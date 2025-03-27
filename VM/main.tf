provider "azurerm" {
  features {}
  subscription_id = "da9a301e-7a82-4e73-abb1-e28a503a0adf"
}

# Create a Network Interface (NIC) for the VM
resource "azurerm_network_interface" "vm_nic" {
  name                = "thesis-vm-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id # Uses the subnet from VNet
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.100" # Assign a static IP from the subnet range
  }
}

# Create the Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "thesis-vm"
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.vm_nic.id]
  size                  = "Standard_B1s"

  admin_username = "adminuser"

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub") # Ensure this key exists
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}
