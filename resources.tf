resource "azurerm_resource_group" "rgg" {
  name     = local.rg_name
  location = "East US"
}


resource "azurerm_virtual_network" "main" {
  name                = local.VN_name
  address_space       = ["10.0.0.0/16"]
  location            = local.location
  resource_group_name = local.rg_name
  depends_on = [ azurerm_resource_group.rgg,
   ]
}

resource "azurerm_subnet" "subnet1" {
  name                 = local.subnet[0].name
  resource_group_name  = local.rg_name
  virtual_network_name = local.VN_name
  address_prefixes     = [local.subnet[0].address_prefix]
  depends_on = [
    azurerm_resource_group.rgg,
    azurerm_virtual_network.main ]
}

resource "azurerm_subnet" "subnet2" {
  name                 = local.subnet[1].name
  resource_group_name  = local.rg_name
  virtual_network_name = local.VN_name
  address_prefixes     = [local.subnet[1].address_prefix]
  depends_on = [
    azurerm_resource_group.rgg,
    azurerm_virtual_network.main ]
}

resource "azurerm_public_ip" "pubip" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = local.rg_name
  location            = local.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "Network_interface" {
  name                = "NicVM"
  location            = local.location
  resource_group_name = local.rg_name
  depends_on = [
    azurerm_resource_group.rgg,
    azurerm_virtual_network.main ]

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pubip.id
  
  }
}

resource "azurerm_windows_virtual_machine" "VM" {
  name                = local.VM_name
  resource_group_name = local.rg_name
  location            = local.location
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.Network_interface.id,
  ]

  depends_on = [
    azurerm_resource_group.rgg,
    azurerm_virtual_network.main,
    azurerm_network_interface.Network_interface ]

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

//below is for adding ST to network interface



resource "azurerm_network_security_group" "appnsg" {
  name                = "app-nsg"
  location            = local.location
  resource_group_name = local.rg_name
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
    azurerm_virtual_network.main,
    azurerm_resource_group.rgg
  ]
}
resource "azurerm_network_interface_security_group_association" "appnsg-link" {
  network_interface_id      = azurerm_network_interface.Network_interface.id
  network_security_group_id = azurerm_network_security_group.appnsg.id
  
  depends_on = [
    azurerm_virtual_network.main,
    azurerm_network_security_group.appnsg,
    azurerm_network_interface.Network_interface
  ]
}

