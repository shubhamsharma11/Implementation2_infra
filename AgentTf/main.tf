provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rgagent01" {
  name     = "rg_agent"
  location = "East US"
}

resource "azurerm_storage_account" "saagent01" {
  name                     = "storageaccountagentshub"
  resource_group_name      = azurerm_resource_group.rgagent01.name
  location                 = azurerm_resource_group.rgagent01.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "agentcont01" {
  name                  = "agent-container"
  storage_account_name  = azurerm_storage_account.saagent01.name
  container_access_type = "private"
}


# Virtual Machine

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "vnet01" {
    name = "agent_vnet"
    resource_group_name = azurerm_resource_group.rgagent01.name
    location = azurerm_resource_group.rgagent01.location
    address_space = ["10.0.0.0/16"]
}

resource "azurerm_public_ip" "publicip01" {
    name = "publiciptest01"
    location = azurerm_resource_group.rgagent01.location
    resource_group_name = azurerm_resource_group.rgagent01.name
    allocation_method = "Static"
}

resource "azurerm_network_interface" "nic01" {
    name = "nic_test_01"
    location = azurerm_resource_group.rgagent01.location
    resource_group_name = azurerm_resource_group.rgagent01.name
    ip_configuration {
        name = "internal"
        subnet_id = azurerm_subnet.subnet01.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id = azurerm_public_ip.publicip01.id
    }
}

resource "azurerm_subnet" "subnet01" {
    name = "agent_subnet"
    resource_group_name = azurerm_resource_group.rgagent01.name
    virtual_network_name = azurerm_virtual_network.vnet01.name
    address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_virtual_machine" "vm01" {
    name = "vm_test_01"
    location = azurerm_resource_group.rgagent01.location
    resource_group_name = azurerm_resource_group.rgagent01.name
    network_interface_ids = [azurerm_network_interface.nic01.id]
    vm_size = "Standard_DS1_v2"
    # ---------------------------------------------------------------------------
    # This line is to follow company policy as boot diagnostics should be enabled
    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.saagent01.primary_blob_endpoint
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
        admin_username = "testadmin"
        admin_password = "Password1234!"
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
} 

resource "null_resource" "execute_script" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir myagent && cd myagent",
      "wget -O vsts-agent-linux-x64-3.234.0.tar.gz https://vstsagentpackage.azureedge.net/agent/3.234.0/vsts-agent-linux-x64-3.234.0.tar.gz",
      "tar zxvf vsts-agent-linux-x64-3.234.0.tar.gz",
      "./config.sh --unattended --url https://dev.azure.com/Shubham1708698304552/ --auth pat --token x4x4wzwy7w53ikj54ipzhbnmjjnfohcewotpag7zx27ugkgusqmq --pool Default --agent LinuxAgent01 --acceptTeeEula --replace",
      "./run.sh"
    ]

    connection {
      type        = "ssh"
      user        = "testadmin"
      password    = "Password1234!"
      host        = azurerm_public_ip.publicip01.ip_address
    }
  }
  depends_on = [azurerm_virtual_machine.vm01]
}