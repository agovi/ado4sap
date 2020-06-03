#############################################################################
# VARIABLES
#############################################################################

variable "az_resource_group" {
  type = string
}

variable "az_region" {
  type    = string
  default = "westus2"
}

variable "naming_prefix" {
  type    = string
  default = "sap"
}

##################################################################################
# PROVIDERS
##################################################################################

# Configure the Microsoft Azure Provider 
provider "azurerm" {
    version         = ">2.0.0"
    features    {}
}

##################################################################################
# RESOURCES
##################################################################################
resource "random_integer" "sa_num" {
  min = 10000
  max = 99999
}


resource "azurerm_resource_group" "setup" {
  name     = var.az_resource_group
  location = var.az_region
}

resource "azurerm_storage_account" "sa" {
  name                     = "${lower(var.naming_prefix)}${random_integer.sa_num.result}"
  resource_group_name      = azurerm_resource_group.setup.name
  location                 = azurerm_resource_group.setup.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

resource "azurerm_storage_container" "ct" {
  name                 = "terraform-state"
  storage_account_name = azurerm_storage_account.sa.name

}

data "azurerm_storage_account_sas" "state" {
  connection_string = azurerm_storage_account.sa.primary_connection_string
  https_only        = true

  resource_types {
    service   = true
    container = true
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = timestamp()
  expiry = timeadd(timestamp(), "17520h")

  permissions {
    read    = true
    write   = true
    delete  = true
    list    = true
    add     = true
    create  = true
    update  = false
    process = false
  }
}

#############################################################################
# PROVISIONERS
#############################################################################

resource "null_resource" "post-config" {

  depends_on = [azurerm_storage_container.ct]

  provisioner "local-exec" {
    command = <<EOT
echo 'storage_account_name = "${azurerm_storage_account.sa.name}"' 
echo 'container_name = "terraform-state"' 
echo 'key = "terraform.tfstate"' 
echo 'sas_token = "${data.azurerm_storage_account_sas.state.sas}"' 
EOT
  }
}

##################################################################################
# OUTPUT
##################################################################################

output "storage_account_name" {
  value = azurerm_storage_account.sa.name
}

output "resource_group_name" {
  value = azurerm_resource_group.setup.name
}