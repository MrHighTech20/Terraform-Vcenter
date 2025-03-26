terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = ">= 2.0"
    }
  }
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.datacenter_name
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_resource_pool" "pool" {
  name          = "Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "iso_datastore" {
  name          = "ESXI_1"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "vm_iso" {
  name             = var.vm_name // Nome único para a VM
  resource_pool_id = data.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = var.cpu_count
  memory           = var.memory_size
  guest_id         = var.guest_id

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = "vmxnet3"
  }

  disk {
    label            = "disk0"
    size             = var.disk_size
    eagerly_scrub    = false
    thin_provisioned = true
    unit_number      = 0
  }

  cdrom {
    datastore_id = data.vsphere_datastore.iso_datastore.id
    path         = "ISOs/ubuntu-24.04.1-live-server-amd64.iso"
  }

  extra_config = {
    "guestinfo.userdata"      = base64encode(templatefile("${path.module}/cloud-init.tpl", {
      vm_username    = var.vm_username,
      vm_password    = var.vm_password,
      timezone       = var.timezone,
      initial_username = var.initial_username,
      initial_password = var.initial_password
    }))
    "guestinfo.userdata.encoding" = "base64"
  }

  boot_delay = 10000
  firmware   = "bios"
}

# Outputs para debug
output "vm_name" {
  value = vsphere_virtual_machine.vm_iso.name
}

output "iso_path" {
  value = "ISOs/ubuntu-24.04.1-live-server-amd64.iso"
}

output "iso_datastore" {
  value = data.vsphere_datastore.iso_datastore.name
}
