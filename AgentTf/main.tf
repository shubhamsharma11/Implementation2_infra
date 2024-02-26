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
