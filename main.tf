
terraform {
  backend "azurerm" {
    resource_group_name   = "container-resource"
    storage_account_name  = "jenniferstorage"
    container_name        = "jennifercontainer"
    key                   = "terraform.tfstate"
  }
}



provider "azurerm" {
  version  = ">=2.0.0"
  features = {}
}


resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

resource "azurerm_app_service_plan" "example" {
  name                = "example-appserviceplan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "Linux"
  reserved            = true  # Required for Linux

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "jennifer-appservice"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

site_config {
    linux_fx_version = "DOCKER|nginx:latest"
}

  app_settings = {
    "SOME_KEY" = "some-value"
    "WEBSITES_PORT" = "8080" 
  }

  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_role_assignment" "example" {
  principal_id         = azurerm_app_service.example.identity.0.principal_id
  role_definition_name = "Contributor"
  scope                = azurerm_resource_group.example.id
}
