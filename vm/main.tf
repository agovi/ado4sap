# Configure the Microsoft Azure Provider 
provider "azurerm" {
    version         = ">2.0.0"
    features    {}
}

# Create a resource group if it doesn’t exist
resource "azurerm_resource_group" "rg" {
    name                = var.az_resource_group
    location            = var.az_region
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-ado4sap"
  location            =  azurerm_resource_group.rg.location
  resource_group_name =  azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/21"]
}

resource "azurerm_subnet" "subnet" {
  name                      = "sap-subnet"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  address_prefix            = "10.0.0.0/24"
}


# # Generate random text for a unique storage account name.
# resource "random_id" "randomId" {
#   keepers = {
#     # Generate a new id only when a new resource group is defined.
#     resource_group = azurerm_resource_group.rg.name
#   }

#   byte_length = 8
# }

# # Create storage account for boot diagnostics
# resource "azurerm_storage_account" "bootdiagstorageaccount" {
#   name                     = "diag${random_id.randomId.hex}"
#   resource_group_name      = var.az_resource_group
#   location                 = var.az_region
#   account_tier             = "Standard"
#   account_replication_type = "LRS"

#   tags = {
#     environment = "Terraform SAP HANA deployment"
#   }
# }

# # All disks that are in the storage_disk_sizes_gb list will be created
# resource "azurerm_managed_disk" "disk" {
#   count                = length(var.storage_disk_sizes_gb)
#   name                 = "${var.name}-disk${count.index}"
#   location             = var.az_region
#   storage_account_type = "Premium_LRS"
#   resource_group_name  = var.az_resource_group
#   disk_size_gb         = var.storage_disk_sizes_gb[count.index]
#   create_option        = "Empty"
# }

# # All of the disks created above will now be attached to the VM
# resource "azurerm_virtual_machine_data_disk_attachment" "disk" {
#   count              = length(var.storage_disk_sizes_gb)
#   virtual_machine_id = azurerm_virtual_machine.vm.id
#   managed_disk_id    = element(azurerm_managed_disk.disk.*.id, count.index)
#   lun                = count.index
#   caching            = "ReadWrite"
# }

# # Create network interface
# resource "azurerm_network_interface" "nic" {
#     name                      = "${var.name}-nic"
#     location                  = var.az_region
#     resource_group_name       = azurerm_resource_group.rg.name

#     ip_configuration {
#         name                          = "${var.name}-ip"
#         subnet_id                     = azurerm_subnet.subnet.id
#         private_ip_address_allocation = "Dynamic"
#     }

#     tags = {
#         environment = "Terraform Demo"
#     }
# }

# # Create virtual machine
# resource "azurerm_virtual_machine" "vm" {
# #    availability_set_id   = azurerm_availability_set.avsets.id
#     name                  = var.az_resource_group
#     location              = var.az_region
#     resource_group_name   = azurerm_resource_group.rg.name
#     network_interface_ids = [azurerm_network_interface.nic.id]
#     vm_size               = var.vmsize

#     storage_os_disk {
#         name              = "${var.name}-OsDisk"
#         caching           = "ReadWrite"
#         create_option     = "FromImage"
#         managed_disk_type = "Premium_LRS"
#     }

#     storage_image_reference {
#         publisher = "RedHat"
#         offer     = "RHEL-SAP-HA"
#         sku       = "7.6"
#         version   = "latest"
#     }

#     os_profile {
#         computer_name  = var.name
#         admin_username = "sapadmin"
#         admin_password = "M1crosoft2019"
#     }

#     os_profile_linux_config {
#         disable_password_authentication = false
#     }

#     boot_diagnostics {
#         enabled = "true"
#         storage_uri = azurerm_storage_account.bootdiagstorageaccount.primary_blob_endpoint
#     }

#     tags = {
#         environment = "Terraform Demo"
#     }
# }