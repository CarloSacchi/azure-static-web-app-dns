terraform {
  backend "azurerm" {
    resource_group_name  = "your-resource-group"
    storage_account_name = "your-storage-account"
    container_name       = "your-container"
    key                  = "your-state-file.tfstate"
  }
}