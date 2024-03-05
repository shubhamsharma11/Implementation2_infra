provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "rgdev" {
  name     = var.rg.name
  location = var.rg.location
}

# Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aksdev" {
  name                = "aksDemo01"
  location            = azurerm_resource_group.rgdev.location
  resource_group_name = azurerm_resource_group.rgdev.name
  dns_prefix          = "k8sdns"
  kubernetes_version  = "1.27.7"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_D2s_v3"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "ed0500e9-b2d5-4435-a119-c0cdf7e9088a"
    client_secret = "77e48ff4-ef17-405e-959d-b597f42a6f20"
  }

  role_based_access_control_enabled = true

  tags = {
    environment = "Demo"
  }
}

# Azure Container Registry (ACR)
resource "azurerm_container_registry" "acrdev" {
  name                = "acrshubdemo01"
  resource_group_name = azurerm_resource_group.rgdev.name
  location            = azurerm_resource_group.rgdev.location
  sku                 = "Basic"
}

# Virtual Machine

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet01" {
    name = var.vnet_name
    resource_group_name = azurerm_resource_group.rgdev.name
    location = azurerm_resource_group.rgdev.location
    address_space = ["10.0.0.0/16"]
}

resource "azurerm_public_ip" "publicip01" {
    name = "publiciptest01"
    location = azurerm_resource_group.rgdev.location
    resource_group_name = azurerm_resource_group.rgdev.name
    allocation_method = "Static"
}

resource "azurerm_network_interface" "nic01" {
    name = "nic_test_01"
    location = azurerm_resource_group.rgdev.location
    resource_group_name = azurerm_resource_group.rgdev.name
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.subnet01.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.publicip01.id
    }
}

resource "azurerm_subnet" "subnet01" {
    name = var.subnet_name
    resource_group_name = azurerm_resource_group.rgdev.name
    virtual_network_name = azurerm_virtual_network.vnet01.name
    address_prefixes = [var.subnet_ip]
}

# ---------------------------------------------------------------------------
# This line is to follow company policy as boot diagnostics should be enabled
/*Create a storage account to create blob storage for the boot diag output*/
resource "azurerm_storage_account" "diagSA01" {
    name = "bootdiagsa021220232"
    resource_group_name = azurerm_resource_group.rgdev.name
    location = azurerm_resource_group.rgdev.location
    account_tier = "${element(split("_", var.boot_diagnostics_sa_type),0)}"
    account_replication_type = "${element(split("_", var.boot_diagnostics_sa_type),1)}"
}

# ---------------------------------------------------------------------------
resource "azurerm_virtual_machine" "vm01" {
    name = "vm_test_01"
    location = azurerm_resource_group.rgdev.location
    resource_group_name = azurerm_resource_group.rgdev.name
    network_interface_ids = [azurerm_network_interface.nic01.id]
    vm_size = "Standard_DS1_v2"
    # ---------------------------------------------------------------------------
    # This line is to follow company policy as boot diagnostics should be enabled
    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.diagSA01.primary_blob_endpoint
    }
    # ---------------------------------------------------------------------------
    # Uncomment this line to delete the OS disk automatically when deleting the VM
    # delete_os_disk_on_termination = true
    # Uncomment this line to delete the data disks automatically when deleting the VM
    # delete_data_disks_on_termination = true
    storage_image_reference {
        publisher = "Canonical"
        offer = "0001-com-ubuntu-server-jammy"
        sku = "22_04-lts"
        version = "latest"
    }
    storage_os_disk {
        name = "myosdisk1"
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name = "hostname"
        admin_username = var.connection["username"]
        admin_password = var.connection["password"]
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
} 

resource "null_resource" "copy_ansible_yaml" {
  triggers = {
    always_run = timestamp()
  }
    provisioner "file" {
      source = "deploy.yaml"
      destination = "/tmp/deploy.yaml"

    connection {
      type        = "ssh"
      user        = var.connection["username"]
      password    = var.connection["password"]
      host        = azurerm_public_ip.publicip01.ip_address
    }
  }
  depends_on = [azurerm_virtual_machine.vm01]
}

# resource "null_resource" "copy_ansible_inventory" {
#   triggers = {
#     always_run = timestamp()
#   }

#   provisioner "file" {
#     content = <<EOF
#     [localhost]
#     ${azurerm_public_ip.publicip01.ip_address}
#     EOF
#     destination = "/tmp/inventory"
    
#     connection {
#       type        = "ssh"
#       user        = var.connection["username"]
#       password    = var.connection["password"]
#       host        = azurerm_public_ip.publicip01.ip_address
#     }
#   }
#   depends_on = [azurerm_virtual_machine.vm01]
# }

resource "null_resource" "copy_script_file" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "file" {
    source = "script.sh"
    destination = "/tmp/script.sh"
    
    connection {
      type        = "ssh"
      user        = var.connection["username"]
      password    = var.connection["password"]
      host        = azurerm_public_ip.publicip01.ip_address
    }
  }
  depends_on = [null_resource.copy_ansible_yaml]
}

resource "null_resource" "execute_script" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh ",
      "/tmp/script.sh"
    ]

    connection {
      type        = "ssh"
      user        = var.connection["username"]
      password    = var.connection["password"]
      host        = azurerm_public_ip.publicip01.ip_address
    }
  }
  depends_on = [null_resource.copy_script_file]
}