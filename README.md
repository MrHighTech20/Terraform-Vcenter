# Terraform-Vcenter
How to create virtual machines using Terraform

This guide explains how to set up a virtual machine (VM) using Terraform with the VMware vSphere provider. The configuration includes creating a VM without a template and setting up the VM manually after creation. For this example, we use Ubuntu Server 24.

---

## Prerequisites

Before you begin, ensure you have the following:

- [Terraform](https://developer.hashicorp.com/terraform/install) installed
- Access to a VMware vCenter Server
- Basic knowledge of Linux

---

## Steps

### 1. **Optional - Install WSL 2**
If you're using Windows, you can install WSL 2 to run Linux. However, Terraform works on any OS, so this step is optional.
Follow Microsoft documentation for installing WS2 - https://learn.microsoft.com/en-us/windows/wsl/install
---

### 2. **Install Terraform**
Follow the steps on the [official Terraform installation page](https://developer.hashicorp.com/terraform/install) to install Terraform on your computer.

---

### 3. **Set Your Environment Variables**
Terraform requires credentials to authenticate with your vCenter. Set these credentials as environment variables in your terminal:

```bash
echo 'export TF_VAR_vsphere_user="your_user@vsphere.local"' >> ~/.bashrc
echo 'export TF_VAR_vsphere_password="your_password"' >> ~/.bashrc
echo 'export TF_VAR_vsphere_server="192.168.*.*"' >> ~/.bashrc
source ~/.bashrc
```

If your vCenter has DNS configured, you can use its hostname instead of the IP address.

Additionally, set other required variables:

```bash
export TF_VAR_datacenter_name="YourDatacenterName"
export TF_VAR_datastore_name="YourDatastoreName"
export TF_VAR_network_name="YourNetworkName"
export TF_VAR_vm_name="UniqueVMName"
export TF_VAR_cpu_count=2
export TF_VAR_memory_size=4096
export TF_VAR_guest_id="ubuntu64Guest"
export TF_VAR_disk_size=20
export TF_VAR_initial_username="admin"
export TF_VAR_initial_password="securepassword"
export TF_VAR_timezone="UTC"
```

Reapply the changes:
```bash
source ~/.bashrc
```

---

### 4. **Create the Terraform Files**

#### **main.tf**
Create a `main.tf` file with the following content:

```hcl
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
  name             = var.vm_name
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
      initial_username = var.initial_username,
      initial_password = var.initial_password,
      timezone         = var.timezone
    }))
    "guestinfo.userdata.encoding" = "base64"
  }

  boot_delay = 10000
  firmware   = "bios"
}

output "vm_name" {
  value = vsphere_virtual_machine.vm_iso.name
}

output "iso_path" {
  value = "ISOs/ubuntu-24.04.1-live-server-amd64.iso"
}

output "iso_datastore" {
  value = data.vsphere_datastore.iso_datastore.name
}
```

#### **variables.tf**
Create a `variables.tf` file to define the variables used in `main.tf`:

```hcl
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
```

---

### 5. **Run Terraform Commands**
After creating the files, initialize Terraform, plan the changes, and apply them:

```bash
terraform init
terraform plan
terraform apply
```

---

### Notes
- Ensure all variables are correctly set in your environment.
- If you encounter errors, verify the `guest_id` and `vm_name` values.
- The `guest_id` must match a valid vSphere guest OS identifier (e.g., `ubuntu64Guest`).
