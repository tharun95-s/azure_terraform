variable "azurerm_resource_group" {
  type = string
  description = "resource group name"
}
variable "location" {
  type = string
  description = "Infrastructure location"
  default = "West US"
}
variable "tags" {
  type = map(string)
  description = "Tags to be applied to all resources"
  default = {
    Environment = "Development"
    Project     = "TerraformDemo"
  }
}
variable "azurerm_virtual_network" {
  type = string
  description = "virtual network"
}
variable "address_space" {
  type = list(string)
  description = "IP address for vnet"
}
variable "azurerm_subnet" {
  type = string
  description = "subnet name"
}
variable "address_prefixes" {
  type = list(string)
  description = "IP address for subnet"
}
variable "azurerm_network_security_group" {
  type = string
  description = "nsg for network"
}
variable "azurerm_public_ip" {
  type = string
  description = "public ip name"
}
variable "azurerm_lb" {
  type = string
  description = "loadbalancer name"
}
variable "frontend_ip_configuration" {
  type = string
  description = "details of frontend ip"
}
variable "azurerm_ssh_public_key" {
  type = string
  description = "SSH public key for VM access"
}