resource "azurerm_resource_group" "Rg4" {
  name     = locals.rg_name
  location = local.location
}

resource "azurerm_virtual_network" "VN4" {
  name                = local.VN4.name
  address_space       = [local.VN4.address_prefixes]
  location            = local.location
  resource_group_name = alocal.rg_name
}

resource "azurerm_subnet" "subnet7" {
  name                 = local.Subnet4.name[0]
  resource_group_name  = local.rg_name
  virtual_network_name = local.VN4.name
  address_prefixes     = [local.Subnet4.name[0]]
}

resource "azurerm_public_ip" "pubip4" {
  name                = "pulicip4"
  location            = local.location
  resource_group_name = local.rg3
  allocation_method   = "Static"
  depends_on = [ azurerm_resource_group.rg22, azurerm_subnet.subnet3 ]
}

resource "azurerm_network_interface" "nic4" {
  name                = "nic4"
  location            = local.location
  resource_group_name = local.rg_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet7.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pubip4.id
  }
}

resource "azurerm_windows_virtual_machine" "VM4" {
  name                = "VM4"
  resource_group_name = local.rg_name
  location            = local.rg_name
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic4.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}


resource "azurerm_network_security_group" "nsg4" {
  name                = "nsg4"
  resource_group_name = local.rg_name
  location            = local.rg_name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  resource "azurerm_subnet_network_security_group_association" "nsgasso4" {
  subnet_id                 = azurerm_subnet.subnet7.id
  network_security_group_id = azurerm_network_security_group.nsg4.id
}