terraform {
    backend "azurerm" {
        resource_group_name = "rg_agent"
        storage_account_name = "storageaccountagentshub"
        container_name = "agent-container"
        key = "terraform.tfstate"
    }
}
