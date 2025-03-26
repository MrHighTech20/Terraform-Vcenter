// Terraform block to specify required providers
terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere" // Specifies the vSphere provider
      version = ">= 2.0"            // Minimum version of the provider
    }
  }
}

// Provider configuration for vSphere
provider "vsphere" {
  user                 = var.vsphere_user         // Username for vSphere authentication
  password             = var.vsphere_password     // Password for vSphere authentication
  vsphere_server       = var.vsphere_server       // vSphere server address
  allow_unverified_ssl = true                     // Allows insecure SSL connections
}

// Data block to fetch information about the vSphere datacenter
data "vsphere_datacenter" "dc" {
  name = var.datacenter_name // Name of the datacenter to fetch
}

// Data block to fetch information about the vSphere datastore
data "vsphere_datastore" "datastore" {
  name          = var.datastore_name             // Name of the datastore
  datacenter_id = data.vsphere_datacenter.dc.id // ID of the datacenter
}

// Data block to fetch information about the vSphere network
data "vsphere_network" "network" {
  name          = var.network_name              // Name of the network
  datacenter_id = data.vsphere_datacenter.dc.id // ID of the datacenter
}

// Data block to fetch information about the vSphere resource pool
data "vsphere_resource_pool" "pool" {
  name          = "Resources"                  // Name of the resource pool
  datacenter_id = data.vsphere_datacenter.dc.id // ID of the datacenter
}

// Data block to fetch information about the datastore where the ISO is located
data "vsphere_datastore" "iso_datastore" {
  name          = "ESXI_1"                     // Name of the ISO datastore
  datacenter_id = data.vsphere_datacenter.dc.id // ID of the datacenter
}

// Resource block to create a virtual machine in vSphere
resource "vsphere_virtual_machine" "vm_iso" {
  name             = var.vm_name // Unique name for the virtual machine
  resource_pool_id = data.vsphere_resource_pool.pool.id // ID of the resource pool
  datastore_id     = data.vsphere_datastore.datastore.id // ID of the datastore
  num_cpus         = var.cpu_count                     // Number of CPUs for the VM
  memory           = var.memory_size                  // Memory size in MB for the VM
  guest_id         = var.guest_id                     // Guest OS identifier

  // Network interface configuration
  network_interface {
    network_id   = data.vsphere_network.network.id // ID of the network
    adapter_type = "vmxnet3"                       // Type of network adapter
  }

  // Configuration for the primary disk of the VM
  disk {
    label            = "disk0"                  // Label for the disk
    size             = var.disk_size            // Disk size in GB
    eagerly_scrub    = false                    // Do not allocate disk space immediately
    thin_provisioned = true                     // Use thin provisioning
    unit_number      = 0                        // Disk unit number
  }

  // Configuration for the CD-ROM to load an ISO
  cdrom {
    datastore_id = data.vsphere_datastore.iso_datastore.id // ID of the datastore containing the ISO
    path         = "ISOs/ubuntu-24.04.1-live-server-amd64.iso" // Path to the ISO file
  }

  boot_delay = 10000 // Boot delay in milliseconds (10 seconds)
  firmware   = "bios" // Use BIOS as the firmware
}

// Output block to display the name of the created virtual machine
output "vm_name" {
  value = vsphere_virtual_machine.vm_iso.name // Outputs the name of the VM
}

// Output block to display the path of the ISO used
output "iso_path" {
  value = "ISOs/ubuntu-24.04.1-live-server-amd64.iso" // Outputs the ISO path
}

// Output block to display the name of the datastore containing the ISO
output "iso_datastore" {
  value = data.vsphere_datastore.iso_datastore.name // Outputs the name of the ISO datastore
}
