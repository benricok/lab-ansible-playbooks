## Packages needed from apt:
 - ansible
 - sshpass
 - terraform
 - kubernetes-client

## Packages need from pip:
 - netaddr

## debian-cloud-template.yml
 - Replace ```<proxmox ip>``` with your pve host ip, you can add multiple hosts separated by a comma (leave comma if only using one host)
 - Will ask your ssh password
   
```ansible-playbook -i <proxmox ip>, debian-cloud-template.yml -k```

## Generate ssh-keypair for k3s cluster
Leave passphrase empty
```
ssh-keygen -f ~/.ssh/id_k3s
```

## Deploy k3s cluser with Terraform & Ansible
- Export the following ENV secrets
```
export TF_VAR_pve_user=<pve user>
export TF_VAR_pve_password=<pve password>
export TF_VAR_ssh_keyfile=<ssh id_k3s.pub key>
```

- Edit terraform vars
```
cd terraform 
vim variables.tfvars
```

- Run terraform
```
terraform init
terraform plan -var-file=variables.tfvars
terraform apply -var-file=variables.tfvars
```
- Terraform will generate the template hosts.ini and all.yml files under your specified cluster name in the inventory folder and deploy the vms on your proxmox host

- Next run the following to setup the k3s nodes
```
cd ..
ansible-galaxy install -r ./collections/requirements.yml
ansible-playbook site.yml
```

