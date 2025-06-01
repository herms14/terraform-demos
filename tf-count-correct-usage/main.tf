provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "count-diag-demo-rg"
  location = "East US"
}

resource "azurerm_storage_account" "sa" {
  name                     = "countdiagdemo${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "countdiagdemo-law-${random_id.suffix.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_diagnostic_setting" "diag" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "diag-settings"
  target_resource_id         = azurerm_storage_account.sa.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = false
      days    = 0
    }
  }

 
}
//terraform apply -var="enable_diagnostics=true" --auto-approve
