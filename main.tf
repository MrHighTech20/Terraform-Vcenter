# main.tf
# Configure you provider, in this case one server vcenter (vsphere)
provider "vsphere" {
  user           = "adminstrator@mvrc.local"
  password       = "Mvrc#2022"
  vsphere_server = "192.168.31.13"
}

# Set your datacenter created on vcenter
data "vsphere_datacenter" "dc" {
  name = "MVRC-DC"
}

## If you was one cluse, set here
#data "vsphere_datastore_cluster" "datastore_cluster" {
#  name          = "Xeon"
#  datacenter_id = data.vsphere_datacenter.dc.id
#}

# Set parameters for your VM
resource "vsphere_virtual_machine" "ubuntu_vm" {
  name             = "UbuntuServer"
  #resource_pool_id = data.vsphere_cluster.cluster.resource_pool_id
  datastore_id     = "ESX2"
  folder           = "Ubuntu_Server"

  num_cpus = 2
  memory   = 4096

  guest_id = "ubuntu64Guest"

  network_interface {
    network_id = "VM Network"
  }

  disk {
    label = "disk0"
    size  = 20
  }

  #cdrom {
  #  datastore_iso_file = "seu_iso_path"
  #}

  # Set up for template
  clone {
    template_uuid = "UbuntuServer"
  }

  # Adicione a chave pública à VM
  provisioner "file" {
    source      = "/root/.ssh/id_rsa"
    destination = "/home/ubuntu/.ssh/authorized_keys"
  }
}


