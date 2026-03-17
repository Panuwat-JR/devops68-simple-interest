terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Resource Group (เปลี่ยนชื่อใหม่เพื่อไม่ให้ซ้ำกับของเดิม)
resource "azurerm_resource_group" "rg" {
  name     = "RG-PANUW-DEVOPS68" 
  location = "Central US" 
}

# 2. Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-panuw-devops68"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 3. Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet-panuw-devops68"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Public IP (เลข IP ใหม่)
resource "azurerm_public_ip" "public_ip" {
  name                = "pip-panuw-devops68"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 5. Network Interface (การ์ดแลนใหม่)
resource "azurerm_network_interface" "nic" {
  name                = "nic-panuw-devops68"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# 6. Virtual Machine (ชื่อเครื่องใหม่ แต่สเปคแรงเหมือนเดิม)
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-panuw-devops68"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2s_v3" 
  admin_username      = "adminuser"    
  admin_password      = "Student@2026!!" 
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

# 7. Network Security Group (NSG ใหม่)
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-panuw-devops68"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 8. เชื่อมต่อ NSG เข้ากับ NIC
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}