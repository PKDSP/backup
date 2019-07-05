variable "aws_key_path" {
  description = "Enter key path"
}
variable "aws_key_name" {
  description = "Enter key name"
}
variable "aws_region" {
  description = "Enter the aws region Example(Mumbai,us-west-2)"
}
variable "aws_access_key" {
  description = "Enter the user aws access key"
}
variable "aws_secret_key" {
  description = "Enter the user aws access key"
}
variable "aws_vpc_cidr" {
  description = "CIDR block for Virtual Network"
}
variable "aws_public_subnet_cidr" {
  description = "CIDR block for Subnet within a Virtual Network"
}
variable "aws_private_subnet_cidr" {
  description = "CIDR block for Subnet within a Virtual Network"
}
variable "aws_ami" {
  description = "Enter the image id ami-0d773a3b7bb2bb1c1"
}
variable "pvtkey" {
  description ="Enter the pem file path"
}
variable "tags" {
  type = "map"
  description = "Enter tags name"
}
variable "availability_zones" {
  # No spaces allowed between az names!
  default = ["us-west-2a","us-west-2b","us-west-2c"]
}

