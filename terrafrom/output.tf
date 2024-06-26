
output "Master-Hostnames" {
  value = ["${proxmox_vm_qemu.proxmox_vm_masters.*.name}"]
}

output "Worker-Hostnames" {
  value = ["${proxmox_vm_qemu.proxmox_vm_workers.*.name}"]
}

output "Master-IPs" {
  value = ["${proxmox_vm_qemu.proxmox_vm_masters.*.default_ipv4_address}"]
}

output "Worker-IPs" {
  value = ["${proxmox_vm_qemu.proxmox_vm_workers.*.default_ipv4_address}"]
}

output "Username" {
  value = "k3s_admin"
}