terraform {
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://192.168.1.200:8006/api2/json"
  pm_user     = var.pm_user
  pm_password = var.pm_password
  # pm_insecure  = true
}