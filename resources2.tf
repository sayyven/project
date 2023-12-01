resource "azurerm_resource_group" "rg22" {
  name     = local.rg_name2
  location = local.location2
}

resource "azurerm_virtual_network" "VN2" {
  name                = local.VN2.name
  address_space       = [local.VN2.address_space]
  location            = local.location2
  resource_group_name = local.rg_name2
  depends_on = [ azurerm_resource_group.rg22 ]
}

resource "azurerm_subnet" "subnet3" {
  name                 = local.subnet22[0].name
  resource_group_name  = local.rg_name2
  virtual_network_name = local.VN2.name
  address_prefixes     = [local.subnet22[0].address_prefix]
  depends_on = [ azurerm_virtual_network.VN2 ]
}

# resource "azurerm_subnet" "subnet4" {
#   name                 = local.subnet22[1].name
#   resource_group_name  = local.rg_name2
#   virtual_network_name = local.VN2.name
#   address_prefixes     = [local.subnet22[1].address_prefix]
#   depends_on = [ azurerm_virtual_network.VN2 ]

# }

resource "azurerm_public_ip" "pubip2" {
  name                = "pulicip2"
  location            = local.location2
  resource_group_name = local.rg_name2
  allocation_method   = "Static"
  depends_on = [ azurerm_resource_group.rg22, azurerm_subnet.subnet3 ]
}


resource "azurerm_network_interface" "nic2" {
  name                = "nic2"
  location            = local.location2
  resource_group_name = local.rg_name2
  depends_on = [ azurerm_resource_group.rg22 ]

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet3.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pubip2.id
  }
}

resource "azurerm_windows_virtual_machine" "VM22" {
  name                = "VM22"
  location            = local.location2
  resource_group_name = local.rg_name2
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic2.id,
  ]
depends_on = [ azurerm_resource_group.rg22, azurerm_subnet.subnet3 ]
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}


resource "azurerm_network_security_group" "appnsg2" {
  name                = "app-nsg2"
  location            = local.location2
  resource_group_name = local.rg_name2
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
depends_on = [
    azurerm_virtual_network.VN2,
    azurerm_resource_group.rg22
  ]
}
resource "azurerm_network_interface_security_group_association" "appnsg-link2" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.appnsg2.id
  
  depends_on = [
    azurerm_virtual_network.VN2,
    azurerm_network_security_group.appnsg2,
    azurerm_network_interface.nic2
  ]
}