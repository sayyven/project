resource "azurerm_resource_group" "rg3" {
  name     = local.rg3
  location = local.location
}

resource "azurerm_virtual_network" "VN3" {
  name                = local.vn3.name
  address_space       = [local.vn3.address_space]
  location            = local.location
  resource_group_name = local.rg3
  depends_on = [ azurerm_resource_group.rg3 ]
}

resource "azurerm_subnet" "subnet5" {
  name                 = local.subnet33[0].name
  resource_group_name  = local.rg3
  virtual_network_name = local.vn3.name
  address_prefixes     = [local.subnet33[0].address_prefixes]
  depends_on = [ azurerm_resource_group.rg3, azurerm_virtual_network.VN3 ]
}

# resource "azurerm_subnet" "subnet6" {
#   name                 = local.subnet33[1].name
#   resource_group_name  = local.rg3
#   virtual_network_name = local.vn3.name
#   address_prefixes     = [local.subnet33[1].address_prefixes]
#   depends_on = [ azurerm_resource_group.rg3, azurerm_virtual_network.VN3 ]
# }

resource "azurerm_public_ip" "pubip3" {
  name                = "pulicip3"
  location            = local.location
  resource_group_name = local.rg3
  allocation_method   = "Static"
  depends_on = [ azurerm_resource_group.rg22, azurerm_subnet.subnet3 ]
}


resource "azurerm_network_interface" "netint3" {
  name                = "nic3"
  location            = local.location
  resource_group_name = local.rg3
  depends_on = [ azurerm_resource_group.rg3, azurerm_virtual_network.VN3 ]


  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet5.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pubip3.id
    
  }
}

resource "azurerm_windows_virtual_machine" "vn3" {
  name                = "VM3"
  location            = local.location
  resource_group_name = local.rg3
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.netint3.id

  ]
depends_on = [ azurerm_resource_group.rg3, azurerm_virtual_network.VN3, azurerm_network_interface.netint3 ]

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