variable "pm_password" {
  description = "Description of proxmox password"
  type        = string
}

variable "pm_user" {
  description = "Description of proxmox user"
  type        = string
}
variable "vm_count" {
  type    = number
  default = 3
}