variable "pve_tls_insecure" {
  description = "Set to true to ignore certificate errors"
  type        = bool
  default     = false
}

variable "pve_host" {
  description = "The hostname or IP of the proxmox server"
  type        = string
}

variable "pve_user" {
  type = string
  default = "root@pam"
  sensitive = false
}

variable "node_user" {
  type = string
  default = "k3s_admin"
  sensitive = false
}

variable "pve_password" {
  type = string
  sensitive = true
}

variable "ssh_keyfile" {
  type = string
}

variable "pve_node_name" {
  description = "name of the proxmox node to create the VMs on"
  type        = string
  default     = "pve"
}

variable "pvt_key" {}

variable "cluster_name" {
  default = "my-cluster"
}

variable "vm_storage" {
  default = "local-lvm"
}

variable "k3s_masters" {
  default = 1
}

variable "k3s_master_mem" {
  default = "4096"
}

variable "k3s_master_cores" {
  default = "2"
}

variable "k3s_master_disk_size" {
  default = "10"
}

variable "k3s_workers" {
  default = 2
}

variable "k3s_worker_mem" {
  default = "4096"
}

variable "k3s_worker_cores" {
  default = "2"
}

variable "k3s_worker_disk_size" {
  default = "10"
}

variable "template_vm_name" {}

variable "master_ips" {
  description = "List of ip addresses for master nodes"
}

variable "worker_ips" {
  description = "List of ip addresses for worker nodes"
}

variable "networkrange" {
  default = 24
}

variable "gateway" {
  default = "192.168.88.1"
}

variable "timezone" {
  default = "Africa/Johannesburg"
}

variable "apiserver_endpoint" {
  default = "192.168.3.100"
}

variable "k3s_token" {
  default = "some-SUPER-DEDEUPER-secret-password"
}

variable "metal_lb_ip_range" {
  default = "192.168.3.140-192.168.3.150"
}
