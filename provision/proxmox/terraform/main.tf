resource "proxmox_vm_qemu" "my_vm" {
  count       = var.vm_count
  name        = "vm${count.index+1}"
  desc        = "focal server description"
  target_node = "pve"
  scsihw      = "virtio-scsi-single"
  clone       = "template"

  disk {
    size    = "15G"
    type    = "scsi"
    storage = "local-lvm"
  }
  sockets = 4
  cores   = 2
  memory  = 8192

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  
  ipconfig0 = "ip=192.168.1.23${count.index+1}/24,gw=192.168.1.1"

}