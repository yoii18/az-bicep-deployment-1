terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">1.9.1"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  use_oidc = true
}
