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
    type = list
    default = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "subnet_name" {
    type = list
    default = ["subnet_test_1", "subnet_test_2", "subnet_test_3"]
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
