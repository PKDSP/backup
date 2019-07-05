output "network_interface_private_ip" {
  description = "private ip addresses of the vm nics"
  value       = "${azurerm_network_interface.terraformNetworkInterface.private_ip_address}"
}
output "public_ip_address" {
  description = "The actual ip address allocated for the resource."
  value       = "${data.azurerm_public_ip.terraformPublicIPAddress.ip_address}"
}