terraform {
  required_version = ">= 1.8, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">1.9.1"
    }
  }
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "resourceGroup" {
  name     = "arm-introduction-02-cli"
  location = "Japan East"
}

resource "azurerm_storage_account" "strgAcct" {
  name                     = "tfstrgacctabcd101"
  location                 = azurerm_resource_group.resourceGroup.location
  resource_group_name      = azurerm_resource_group.resourceGroup.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "DEV"
  }
}


