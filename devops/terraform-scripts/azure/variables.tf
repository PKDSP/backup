variable "subscription_id" {
  description = "ID of the subscription to be deployed to (should be GUID, not Name)"
}
variable "client_id" {
  description = "Enter Client ID for Application created in Azure AD"
}
variable "client_secret" {
  description = "Enter Client secret for Application in Azure AD"
}
variable "tenant_id" {
  description =	"The tenant id for the subscription"
}
variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "terraform-compute"
}
variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
}
variable "virtual_network_name" {
  description = "The name of the virtual network in which the resources will be created"
}
variable "vnet_cidr" {
  description = "CIDR block for Virtual Network"
}
variable "subnet1_cidr" {
  description = "CIDR block for Subnet within a Virtual Network"
}
variable "vm_username" {
  description = "Enter admin username to SSH into Linux VM"
}
variable "vm_password" {
  description = "Enter admin password to SSH into VM"
}
variable "tags" {
  type = "map"
  description = "Enter tags name"
}