// Define a resource to create a virtual machine in vSphere using cloud-init
resource "vsphere_virtual_machine" "vm_cloud_init" {
  // Name of the virtual machine
  name             = var.vm_name

  // ID of the resource pool where the VM will be created
  resource_pool_id = data.vsphere_resource_pool.pool.id

  // ID of the datastore where the VM's disks will be stored
  datastore_id     = data.vsphere_datastore.datastore.id

  // Hardware configuration: number of CPUs and amount of memory
  num_cpus         = var.cpu_count
  memory           = var.memory_size

  // Identifier for the guest operating system (guest OS)
  guest_id         = var.guest_id

  // Network interface configuration
  network_interface {
    // ID of the network where the VM will be connected
    network_id   = data.vsphere_network.network.id

    // Type of network adapter
    adapter_type = "vmxnet3"
  }

  // Configuration for the primary disk of the VM
  disk {
    // Label for the disk
    label            = "disk0"

    // Size of the disk in GB
    size             = var.disk_size

    // Additional disk configurations
    eagerly_scrub    = false // Do not allocate disk space immediately
    thin_provisioned = true  // Use thin provisioning
    unit_number      = 0     // Disk unit number
  }

  // Configuration for the CD-ROM to load an ISO
  cdrom {
    // ID of the datastore where the ISO is located
    datastore_id = data.vsphere_datastore.iso_datastore.id

    // Path to the ISO in the datastore
    path         = "ISOs/ubuntu-24.04.1-live-server-amd64.iso"
  }

  // Cloud-init configuration to customize the VM during initialization
  extra_config = {
    // Passes the cloud-init data as a base64-encoded string
    "guestinfo.userdata"      = base64encode(templatefile("${path.module}/cloud-init.tpl", {
      // Variables used in the cloud-init.tpl file
      initial_username = var.initial_username,
      initial_password = var.initial_password,
      timezone         = var.timezone
    }))

    // Specifies that the cloud-init data is base64 encoded
    "guestinfo.userdata.encoding" = "base64"
  }

  // Boot delay and firmware configuration for the VM
  boot_delay = 10000 // Boot delay of 10 seconds
  firmware   = "bios" // Use BIOS as the firmware
}

// Output block to verify the name of the created virtual machine
output "vm_cloud_init_name" {
  // Displays the name of the created virtual machine
  value = vsphere_virtual_machine.vm_cloud_init.name
}