variable "env" {
  type    = string
  default = "Production"
}

variable "rg" {
  type    = map
  default = {
    "name"     = "rg_prod"
    "location" = "East US"
  }
}

variable "vnet_name" {
    type    = string
    default = "vnet_dev"
}

variable "subnet_ip" {
    type = string
    default = "10.0.0.0/24"
}

variable "subnet_name" {
    type = string
    default = "subnet_dev"
}

variable "boot_diagnostics_sa_type" {
    default = "Standard_LRS"
}

variable "connection" {
 type = map
 default = {
 "username" = "testadmin"
 "password" = "Password1234!"
 }
}
