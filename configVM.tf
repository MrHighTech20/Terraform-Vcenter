// Define um recurso para criar uma máquina virtual no vSphere usando o cloud-init
resource "vsphere_virtual_machine" "vm_cloud_init" {
  // Nome da máquina virtual
  name             = var.vm_name

  // ID do resource pool onde a VM será criada
  resource_pool_id = data.vsphere_resource_pool.pool.id

  // ID do datastore onde os discos da VM serão armazenados
  datastore_id     = data.vsphere_datastore.datastore.id

  // Configuração de hardware: número de CPUs e quantidade de memória
  num_cpus         = var.cpu_count
  memory           = var.memory_size

  // Identificador do sistema operacional convidado (guest OS)
  guest_id         = var.guest_id

  // Configuração da interface de rede
  network_interface {
    // ID da rede onde a VM será conectada
    network_id   = data.vsphere_network.network.id

    // Tipo de adaptador de rede
    adapter_type = "vmxnet3"
  }

  // Configuração do disco principal da VM
  disk {
    // Rótulo do disco
    label            = "disk0"

    // Tamanho do disco em GB
    size             = var.disk_size

    // Configurações adicionais do disco
    eagerly_scrub    = false
    thin_provisioned = true
    unit_number      = 0
  }

  // Configuração do CD-ROM para carregar uma ISO
  cdrom {
    // ID do datastore onde a ISO está localizada
    datastore_id = data.vsphere_datastore.iso_datastore.id

    // Caminho para a ISO no datastore
    path         = "ISOs/ubuntu-24.04.1-live-server-amd64.iso"
  }

  // Configuração do cloud-init para personalizar a VM durante a inicialização
  extra_config = {
    // Passa os dados do cloud-init como uma string codificada em base64
    "guestinfo.userdata"      = base64encode(templatefile("${path.module}/cloud-init.tpl", {
      // Variáveis usadas no arquivo cloud-init.tpl
      initial_username = var.initial_username,
      initial_password = var.initial_password,
      timezone         = var.timezone
    }))

    // Especifica que os dados do cloud-init estão codificados em base64
    "guestinfo.userdata.encoding" = "base64"
  }

  // Configuração de atraso no boot e firmware da VM
  boot_delay = 10000 // Atraso de 10 segundos no boot
  firmware   = "bios" // Usa BIOS como firmware
}

// Output para verificar o nome da máquina virtual criada
output "vm_cloud_init_name" {
  // Exibe o nome da máquina virtual criada
  value = vsphere_virtual_machine.vm_cloud_init.name
}