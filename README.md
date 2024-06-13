### Packages needed:
 - ansible
 - sshpass

### pve-vm-template-deb-12-cloudinit-playbook.yml
 - Replace ```<proxmox ip>``` with your pve host ip, you can add multiple hosts separated by a comma (leave comma if only using one host)
 - Will ask your ssh password
   
```ansible-playbook -i <proxmox ip>, pve-vm-template-deb-12-cloudinit-playbook.yml -k```
