variable "vsphere_user" {
  description = "Username for vSphere authentication"
  type        = string
}

variable "vsphere_password" {
  description = "Password for vSphere authentication"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vSphere server address"
  type        = string
}

variable "datacenter_name" {
  description = "Name of the vSphere datacenter"
  type        = string
}

variable "datastore_name" {
  description = "Name of the vSphere datastore"
  type        = string
}

variable "network_name" {
  description = "Name of the vSphere network"
  type        = string
}

variable "vm_name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "cpu_count" {
  description = "Number of CPUs for the virtual machine"
  type        = number
}

variable "memory_size" {
  description = "Memory size (in MB) for the virtual machine"
  type        = number
}

variable "guest_id" {
  description = "Guest OS identifier for the virtual machine"
  type        = string
}

variable "disk_size" {
  description = "Disk size (in GB) for the virtual machine"
  type        = number
}

variable "initial_username" {
  description = "Initial username for the virtual machine"
  type        = string
}

variable "initial_password" {
  description = "Initial password for the virtual machine"
  type        = string
  sensitive   = true
}

variable "timezone" {
  description = "Timezone for the virtual machine"
  type        = string
}