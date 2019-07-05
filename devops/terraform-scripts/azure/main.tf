provider "azurerm" {
	subscription_id = "${var.subscription_id}"
	client_id       = "${var.client_id}"
	client_secret   = "${var.client_secret}"
	tenant_id       = "${var.tenant_id}"
    skip_provider_registration = "true"
}
# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "terraformResourceGroup" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
  tags     = "${var.tags}"
}
# Create virtual network
resource "azurerm_virtual_network" "terraformVirtualNetwork" {
    name                = "${var.virtual_network_name}"
    address_space       = ["${var.vnet_cidr}"]
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.terraformResourceGroup.name}"
    tags                = "${var.tags}"
}
# Create subnet
resource "azurerm_subnet" "terraformSubnet" {
    name                 = "Subnet-1"
    resource_group_name  = "${azurerm_resource_group.terraformResourceGroup.name}"
    virtual_network_name = "${azurerm_virtual_network.terraformVirtualNetwork.name}"
    address_prefix       = "${var.subnet1_cidr}"
}
# Create public IPs
resource "azurerm_public_ip" "terraformPublicIP" {
    name                         = "PublicIP"
    location                     = "${var.location}"
    resource_group_name          = "${azurerm_resource_group.terraformResourceGroup.name}"
    public_ip_address_allocation = "dynamic"
    tags                         = "${var.tags}"
}
# Create Network Security Group and rule
resource "azurerm_network_security_group" "terraformNetworkSecurityGroup" {
    name                = "NetworkSecurityGroup"
    location            = "${var.location}"
    resource_group_name = "${azurerm_resource_group.terraformResourceGroup.name}"

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    tags                           = "${var.tags}"
}
# Create network interface
resource "azurerm_network_interface" "terraformNetworkInterface" {
    name                      = "NIC"
    location                  = "${var.location}"
    resource_group_name       = "${azurerm_resource_group.terraformResourceGroup.name}"
    network_security_group_id = "${azurerm_network_security_group.terraformNetworkSecurityGroup.id}"

    ip_configuration {
        name                          = "NicConfiguration"
        subnet_id                     = "${azurerm_subnet.terraformSubnet.id}"
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = "${azurerm_public_ip.terraformPublicIP.id}"
    }
    tags                      = "${var.tags}"
}
# Create virtual machine
resource "azurerm_virtual_machine" "terraformVM" {
    name                  = "VM"
    location              = "${var.location}"
    resource_group_name   = "${azurerm_resource_group.terraformResourceGroup.name}"
    network_interface_ids = ["${azurerm_network_interface.terraformNetworkInterface.id}"]
    vm_size               = "Standard_DS1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "16.04.0-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "ubuntuweb"
        admin_username = "${var.vm_username}"
        admin_password = "${var.vm_password}"
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }
    tags                      = "${var.tags}"
}
data "azurerm_public_ip" "terraformPublicIPAddress" {
  name                = "${azurerm_public_ip.terraformPublicIP.name}"
  resource_group_name = "${azurerm_virtual_machine.terraformVM.resource_group_name}"
}
