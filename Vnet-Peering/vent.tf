# Define locatin variable
variable "loc" {
    default = "eastus"
  
}

# Create a resource group
resource "azurerm_resource_group" "TerraVnetRG" {
  name = "TerrafVnetRG"
  location = var.loc

  tags = {
    "Project" = "TerraVnet"
  }
}

# Create a Virtual network1

resource "azurerm_virtual_network" "TerraVnetVN" {
    name = "TerrafVnetVN"
    location = azurerm_resource_group.TerraVnetRG.location 
    resource_group_name = azurerm_resource_group.TerraVnetRG.name
    address_space = [ "10.0.0.0/16" ]

}

# Create subnet under Virtual netowrk1
resource "azurerm_subnet" "TerraVnetSN1" {
  name = "TerraVnetSN"
  virtual_network_name =  azurerm_virtual_network.TerraVnetVN.name 
  resource_group_name = azurerm_resource_group.TerraVnetRG.name
  address_prefix = "10.0.0.0/24"
}

# Create Virtual network2

resource "azurerm_virtual_network" "TerraVnetVN2" {
    name = "TerrafVnetVN2"
    location = azurerm_resource_group.TerraVnetRG.location 
    resource_group_name = azurerm_resource_group.TerraVnetRG.name
    address_space = [ "192.168.0.0/16" ]

}

# Create Subnet2 

resource "azurerm_subnet" "TerraVnetSN2" {
  name = "TerraVnetSN2"
  virtual_network_name =  azurerm_virtual_network.TerraVnetVN2.name 
  resource_group_name = azurerm_resource_group.TerraVnetRG.name
  address_prefix = "192.168.0.0/24"
}

# Create Vnet peering from Vnet to Vnet2

resource "azurerm_virtual_network_peering" "Vnet_Vnet2" {
    name = "Vnet_Vnet2"
    resource_group_name = azurerm_resource_group.TerraVnetRG.name
    virtual_network_name =  azurerm_virtual_network.TerraVnetVN.name
    remote_virtual_network_id = azurerm_virtual_network.TerraVnetVN2.id 
  
}

#Crate Vnet peering from Vnet2 to Vnet

resource "azurerm_virtual_network_peering" "Vnet2_Vnet" {
    name = "Vnet_Vnet2"
    resource_group_name = azurerm_resource_group.TerraVnetRG.name
    virtual_network_name =  azurerm_virtual_network.TerraVnetVN2.name
    remote_virtual_network_id = azurerm_virtual_network.TerraVnetVN.id 
  
}

resource "azurerm_network_interface" "TerraNIC" {
    name = "TerraNIC"
    location = var.loc 
    resource_group_name = azurerm_resource_group.TerraVnetRG.name

    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.TerraVnetSN2.id 
      private_ip_address_allocation = "Dynamic"
#      private_ip_address = "192.168.0.6"
      public_ip_address_id = azurerm_public_ip.TerraPI.id
    }
  
}

# Create a public ip

resource "azurerm_public_ip" "TerraPI" {
    name = "TerraPI"
    resource_group_name = azurerm_resource_group.TerraVnetRG.name
    location = "eastus"
    allocation_method = "Dynamic"

}

resource "azurerm_windows_virtual_machine" "Vm1234" {
    name = "Vm1234"
    resource_group_name = azurerm_resource_group.TerraVnetRG.name
    location = azurerm_resource_group.TerraVnetRG.location 
    size = "Standard_F2"
    admin_username = "suren"
    admin_password = "Azure@123456"
    network_interface_ids = [ azurerm_network_interface.TerraNIC.id ]
    

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
       publisher = "MicrosoftWindowsServer"
       offer     = "WindowsServer"
       sku       = "2016-Datacenter"
       version   = "latest"
    }

}

# Create VM 2

resource "azurerm_network_interface" "TerraNIC2" {
    name = "TerraNIC2"
    location = var.loc 
    resource_group_name = azurerm_resource_group.TerraVnetRG.name

    ip_configuration {
      name = "internal2"
      subnet_id = azurerm_subnet.TerraVnetSN1.id 
      private_ip_address_allocation = "Dynamic"
#      private_ip_address = "192.168.0.6"
#      public_ip_address_id = azurerm_public_ip.TerraPI2.id
    }
  
}

resource "azurerm_public_ip" "TerraPI2" {
    name = "TerraPI2"
    resource_group_name = azurerm_resource_group.TerraVnetRG.name
    location = azurerm_resource_group.TerraVnetRG.location
    allocation_method = "Dynamic"

}

resource "azurerm_windows_virtual_machine" "Vm12345" {
    name = "Vm12345"
    resource_group_name = azurerm_resource_group.TerraVnetRG.name
    location = azurerm_resource_group.TerraVnetRG.location 
    size = "Standard_F2"
    admin_username = "suren"
    admin_password = "Azure@123456"
    network_interface_ids = [ azurerm_network_interface.TerraNIC2.id ]
    

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
       publisher = "MicrosoftWindowsServer"
       offer     = "WindowsServer"
       sku       = "2016-Datacenter"
       version   = "latest"
    }

}