variable "az_region" {
  type    = string
  default = "westus2"
}

variable "az_resource_group" {
  type    = string
  default = "ado4sap"
}

variable "name" {
  type    = string
  default = "sap"
}

variable "vmsize" {
  description = "VM Size"
  default     = "Standard_E2s_v3"
}

# variable "storage_disk_sizes_gb" {
#   description = "List disk sizes in GB for all disks this VM will need"
#   default     = [32, 32]
# }
