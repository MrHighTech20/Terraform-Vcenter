# Terraform-Vcenter
How to create virtual machines using terraform

Hey everyone. I created a Terraform file to use with a vSphere (vCenter server) without template. but after you need config VM, for example I used Ubuntu Server 24. 

# Terraform
This guide explains how to set up a virtual machine (VM) using Terraform with the VMware vSphere provider.

## Prerequisites

Before you begin, ensure you have the following:

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- Access to a VMware vCenter Server
- Knowledge in linux

## Steps

1. **Opitional - install WSL 2**

   I used Linux with WSL because I find it easier, but you can use any OS.

2. **Install Terraform**

   You need access officialy page of Terraform and following the steps to install in your computer.

3. **Set your environment variables with your VCenter credentials**

   Terraform needs to authenticate on your VCenter, but it's need to you credencials for authenticate it, to do this run in the machine's terminal:
 
 
 ```bash
   echo 'export TF_VAR_vsphere_user="your_user@vsphere.local"' >> ~/.bashrc
   echo 'export TF_VAR_vsphere_password="your_password"' >> ~/.bashrc
   echo 'export TF_VAR_vsphere_server="192.168.*.*"' >> ~/.bashrc
   source ~/.bashrc
```
If you have DNS on your VCenter, put its name instead of the IP.

Now your VCenter credencials it's save and don't need to set in your code.

4. **Create main file**

   Next step you need create main.tf file, in this file you need set parameters to create a VM. I set this parameters in my main.tf:

     - Provider;
      - Define parameters to connect of VCenter serve, with the same variables names sets on my OS;
      - VCenter data center;
      - Data store where VM will create;
      - Network interface, my VCenter use vmxnet3;
      - Resorce pool;
      - Datastore where find .iso file to create VM;
      - Resources that my VM will need (VM name, CPU, memory, Datastore size)
      - CD-ROM config to use .iso file
      - Boot delay to mount CD-ROM

   ```bash
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
   
     // Cloud-init configuration to customize the VM during initialization
     extra_config = {
       "guestinfo.userdata"      = base64encode(templatefile("${path.module}/cloud-init.tpl", {
         vm_username    = var.vm_username,         // Username for the VM
         vm_password    = var.vm_password,         // Password for the VM
         timezone       = var.timezone,            // Timezone for the VM
         initial_username = var.initial_username,  // Initial username for the VM
         initial_password = var.initial_password   // Initial password for the VM
       }))
       "guestinfo.userdata.encoding" = "base64"    // Specifies that the userdata is base64 encoded
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
   ```

   

    

   