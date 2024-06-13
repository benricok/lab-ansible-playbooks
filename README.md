### Packages needed:
 - ansible
 - sshpass

### pve-vm-template-deb-12-cloudinit-playbook.yml
 - Replace <proxmox ip> with your pve host ip, you can add multiple separated by comma
 - Will ask your ssh password
   
```ansible-playbook -i <proxmox ip>, playbook.yml -k```
