# Define the Proxmox virtual machine resources
resource "proxmox_vm_qemu" "my_vm" {
  count       = var.vm_count
  name        = "vm${count.index+1}"
  target_node = "pve" 
  os_type      = "l26"
  memory      = 8192
  cores       = 2
  # description = "My VM ${count.index+1}"

  storage     = "hdd"  # Replace with your storage ID
  clone       = "template"   # Replace with your template name

  network {
    model = "virtio"
    bridge    = "vmbr0"
  }
  # provisioner "remote-exec" {
  #   inline = [
  #     "ip addr | grep 'inet' | awk '{print $2}' >> b.txt"
  #   ]
  # }
  # connection {
  #     type        = "ssh"
  #     user        = var.vm_ssh_user
  #     private_key = file(var.vm_ssh_private_key)
  #     host        = self.ipv4_address
  #   }
}
# data "external" "my_vm" {
#   count = var.vm_count
#   name  = "vm1"#external.my_vm[count.index].name
# }
# output "vm_ip_addresses" {
#   value = [for vm in data.external.my_vm : vm.ip_address]
# }