terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

provider "proxmox" {
  pm_api_url      = "https://${var.pve_host}:8006/api2/json"
  pm_user         = var.pve_user
  pm_password     = var.pve_password
  pm_tls_insecure = var.pve_tls_insecure
  pm_parallel     = 10
  pm_timeout      = 600
  #  pm_debug = true
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}

resource "proxmox_vm_qemu" "proxmox_vm_masters" {
  count       = var.k3s_masters
  name        = "${var.cluster_name}-k3s-master-${count.index + 1}"
  target_node = var.pve_node_name
  clone       = var.template_vm_name
  full_clone  = true
  os_type     = "cloud-init"
  agent       = 1
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  memory      = var.k3s_master_mem
  cores       = var.k3s_master_cores

  ipconfig0 = "ip=${var.master_ips[count.index]}/${var.networkrange},gw=${var.gateway}"

  disks {
        scsi {
            scsi0 {
                disk {
                    backup             = false
                    cache              = "none"
                    discard            = true
                    emulatessd         = true
                    iothread           = false
                    mbps_r_burst       = 0.0
                    mbps_r_concurrent  = 0.0
                    mbps_wr_burst      = 0.0
                    mbps_wr_concurrent = 0.0
                    replicate          = true
                    size               = var.k3s_master_disk_size
                    storage            = var.vm_storage
                }
            }
        }
        ide {
          ide3 {
            cloudinit {
              storage = "local-lvm"
            }
          }
        }   
    }

  network {
        bridge    = "vmbr0"
        firewall  = false
        link_down = false
        model  = "virtio"
    }

  lifecycle {
    ignore_changes = [
      ciuser,
      sshkeys,
      disks,
      network
    ]
  }

  ssh_user = var.node_user
  sshkeys = <<EOF
${var.ssh_keyfile}
EOF
}

resource "proxmox_vm_qemu" "proxmox_vm_workers" {
  count       = var.k3s_workers
  name        = "${var.cluster_name}-k3s-worker-${count.index + 1}"
  target_node = var.pve_node_name
  clone       = var.template_vm_name
  full_clone  = true
  os_type     = "cloud-init"
  agent       = 1
  scsihw      = "virtio-scsi-pci"
  bootdisk    = "scsi0"
  memory      = var.k3s_worker_mem
  cores       = var.k3s_worker_cores

  disks {
        scsi {
            scsi0 {
                disk {
                    backup             = true
                    cache              = "none"
                    discard            = true
                    emulatessd         = true
                    iothread           = false
                    mbps_r_burst       = 0.0
                    mbps_r_concurrent  = 0.0
                    mbps_wr_burst      = 0.0
                    mbps_wr_concurrent = 0.0
                    replicate          = true
                    size               = var.k3s_worker_disk_size
                    storage            = var.vm_storage
                }
            }
        }
        ide {
          ide3 {
            cloudinit {
              storage = "local-lvm"
            }
          }
        }   
    }
  
  network {
        bridge    = "vmbr0"
        firewall  = false
        link_down = false
        model  = "virtio"
    }

  ipconfig0 = "ip=${var.worker_ips[count.index]}/${var.networkrange},gw=${var.gateway}"

  lifecycle {
    ignore_changes = [
      ciuser,
      sshkeys,
      disks,
      network
    ]
  }
  ssh_user = var.node_user
  sshkeys = <<EOF
${var.ssh_keyfile}
EOF
}

data "template_file" "hosts" {
  template = file("./templates/hosts.tpl")
  vars = {
    k3s_master_ip = "${join("\n", [for instance in proxmox_vm_qemu.proxmox_vm_masters : join("", [instance.default_ipv4_address, " ansible_ssh_private_key_file=", var.pvt_key])])}"
    k3s_node_ip   = "${join("\n", [for instance in proxmox_vm_qemu.proxmox_vm_workers : join("", [instance.default_ipv4_address, " ansible_ssh_private_key_file=", var.pvt_key])])}"
  }
}

data "template_file" "all" {
  template = file("./templates/all.tpl")
  vars = {
    timezone = var.timezone
    apiserver_endpoint = var.apiserver_endpoint
    k3s_token = var.k3s_token
    metal_lb_ip_range = var.metal_lb_ip_range
  }
}

data "template_file" "ansible-cfg" {
  template = file("./templates/ansible-cfg.tpl")
  vars = {
    cluster_name = var.cluster_name
  }
}


resource "local_file" "hosts_file" {
  content  = data.template_file.hosts.rendered
  filename = "../inventory/${var.cluster_name}/hosts.ini"
}

resource "local_file" "ansible_cfg_file" {
  content  = data.template_file.ansible-cfg.rendered
  filename = "../ansible.cfg"
}

resource "local_file" "all_file" {
  content  = data.template_file.all.rendered
  filename = "../inventory/${var.cluster_name}/group_vars/all.yml"
}


#resource "local_file" "proxmox_file" {
#  source   = "../inventory/sample/group_vars/proxmox.yml"
#  filename = "../inventory/${var.cluster_name}/group_vars/proxmox.yml"
#}