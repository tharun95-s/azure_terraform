terraform {
  required_version = ">= 1.5.0"
  required_providers {
     azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.78.0"
    }
  } 
}
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg_infra99" {
  name     = var.azurerm_resource_group
  location = var.location
  tags     = var.tags 
}
resource "azurerm_virtual_network" "vnet_infra99" {
  name                = var.azurerm_virtual_network
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.azurerm_resource_group
}
resource "azurerm_subnet" "subnet_infra99" {
  name                 = var.azurerm_subnet
  resource_group_name  = var.azurerm_resource_group
  virtual_network_name = var.azurerm_virtual_network
  address_prefixes     = var.address_prefixes
}
resource "azurerm_network_interface" "vnic_infra99" {
  name                = "nic_infra99"
  location            = var.location
  resource_group_name = var.azurerm_resource_group

  ip_configuration {
    name                          = "ipconfig_infra99"
    subnet_id                     = azurerm_subnet.subnet_infra99.id
    private_ip_address_allocation = "Dynamic"
  }
  
}
resource "azurerm_network_security_group" "nsg_infra99" {
  name                = "nsg_infra99"
  location            = var.location
  resource_group_name = var.azurerm_resource_group
  tags                = var.tags
}
resource "azurerm_network_security_rule" "allow_http" {
  name                        = "AllowHTTP"
  priority                    = 103
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.azurerm_resource_group
  network_security_group_name = var.azurerm_network_security_group
}
resource "azurerm_network_security_rule" "allow_https" {
  name                        = "AllowHTTPS"
  priority                    = 104
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.azurerm_resource_group
  network_security_group_name = var.azurerm_network_security_group
}
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 105
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.azurerm_resource_group
  network_security_group_name = var.azurerm_network_security_group
}
resource "azurerm_network_security_group_association" "nsg_subnet_association" {
  network_security_group_id = azurerm_network_security_group.nsg_infra99.id
  subnet_id                 = azurerm_subnet.subnet_infra99.id
}
resource "azurerm_public_ip" "pip_infra99" {
  name = var.azurerm_public_ip
  location = var.location
    resource_group_name = var.azurerm_resource_group
    allocation_method = "static"
    sku = "Standard"
    domain_name_label = "pip-infra99-${random_integer.suffix.result}"
}
resource "azurerm_lb" "lb_infra99" {
  name                = "lb_infra99"
  location            = var.location
  resource_group_name = var.azurerm_resource_group
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration
    public_ip_address_id = azurerm_public_ip.pip_infra99.id
  } 
}
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}
resource "azurerm_lb_backend_address_pool" "bg_pool_infra99" {
  name                = "bg_pool_infra99"
  loadbalancer_id     = azurerm_lb.lb_infra99.id
}
resource "azurerm_lb_probe" "lb_probe_infra99" {
  name                = "lb_probe_infra99"
  loadbalancer_id     = azurerm_lb.lb_infra99.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 15
  number_of_probes    = 2
}
resource "azurerm_lb_rule" "lb_rule_infra99" {
  name                           = "lb_rule_infra99"
  loadbalancer_id                = azurerm_lb.lb_infra99.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = var.frontend_ip_configuration
  probe_id                       = azurerm_lb_probe.lb_probe_infra99.id
}
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}
resource "azurerm_nat_gateway" "nat_gateway_infra99" {
  name                = "nat_gateway_infra99"
  location            = var.location
  resource_group_name = var.azurerm_resource_group
  sku_name            = "Standard"
}
resource "azurerm_nat_gateway_public_ip" "ng_public_infa99" {
  nat_gateway_id     = azurerm_nat_gateway.nat_gateway_infra99.id
  public_ip_address_id = azurerm_public_ip.pip_infra99.id
}
resource "azurerm_subnet_nat_gateway_association" "subnet_nat_gateway_association_infra99" {
  subnet_id      = azurerm_subnet.subnet_infra99.id
  nat_gateway_id = azurerm_nat_gateway.nat_gateway_infra99.id
}
resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}
resource "azurerm_linux_virtual_machine" "linux_vm_infra99" {
  name                  = "linux-vm-infra99"
  location              = var.location
  resource_group_name   = var.azurerm_resource_group
  network_interface_ids = [azurerm_network_interface.vnic_infra99.id]
  size                  = "Standard_DS1_v2"

  admin_username = "azureuser"
  admin_password = "P@ssword1234!"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = var.tags
}
resource "azurerm_linux_virtual_machine_scale_set" "linux_vmss_infra99" {
  name                = "linux-vmss-infra99"
  location            = var.location
  resource_group_name = var.azurerm_resource_group
  sku                 = "Standard_DS1_v2"
  instances           = 2
  admin_username      = "azureuser"
  admin_password      = "P@ssword1234!"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "nicvmss_infra99"
    primary = true

    ip_configuration {
      name                                   = "ipconfigvmss_infra99"
      subnet_id                              = azurerm_subnet.subnet_infra99.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bg_pool_infra99.id]
      primary                                = true
    }
  }

  tags = var.tags
  
}
resource "azurerm_ssh_public_key" "ssh_key_infra99" {
  name                = "ssh-key-infra99"
  location            = var.location
  resource_group_name = var.azurerm_resource_group
  public_key          = var.azurerm_ssh_public_key
}
resource "azurerm_autoscale_setting" "autoscale_infra99" {
  name                = "autoscale-infra99"
  location            = var.location
  resource_group_name = var.azurerm_resource_group
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.linux_vmss_infra99.id

  profile {
    name = "autoscale-profile-infra99"

    capacity {
      minimum = "2"
      maximum = "5"
      default = "2"
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.linux_vmss_infra99.id
        time_grain         = "PT1M"
        statistic         = "Average"
        time_window       = "PT5M"
        time_aggregation  = "Average"
        operator          = "GreaterThan"
        threshold         = 75
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.linux_vmss_infra99.id
        time_grain         = "PT1M"
        statistic         = "Average"
        time_window       = "PT5M"
        time_aggregation  = "Average"
        operator          = "LessThan"
        threshold         = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
resource "azurerm_monitor_activity_log_alert" "monitor_infra99" {
  name                = "monitor-infra99"
  resource_group_name = var.azurerm_resource_group
  scopes              = [azurerm_resource_group.rg_infra99.id]

  criteria {
    category = "Administrative"
    operation_name = "Microsoft.Compute/virtualMachines/write"
    status = "Failed"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action_group_infra99.id
  }
  location = var.location
}
resource "azurerm_monitor_action_group" "action_group_infra99" {
  name                = "action-group-infra99"
  resource_group_name = var.azurerm_resource_group
  short_name          = "aginfra99"

  email_receiver {
    name          = "emailreceiver"
    email_address = "tharun195s@gmail.com"
    }
  }