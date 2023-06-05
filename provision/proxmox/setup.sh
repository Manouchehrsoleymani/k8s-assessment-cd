#! /bin/bash

# echo " initialize terrraform to download povider"
# cd terraform
# terraform init
# if [[ $? -eq 1 ]]; then 
#         echo " there is a problem to download terraform provider "
#         exit 
# fi
# echo " apply terraform to provision new Vitual machine on provider"
# terraform apply -auto-approve | awk '/^vm_ips/{flag=1;next}/^$/{flag=0}flag' | sed 's/^ *//' > ip_addresses.txt
# if [[ $? -eq 1 ]]; then 
#         echo " there is a problem to provision new vms"
#         exit 
# fi
echo " make an inventory ansible file for kubespray to setup Kubenetes cluster"
# cd ..
python3 ./convert_to_ansible_inventory.py ip_addresses.txt > inventory.ini
if [[ $? -eq 1 ]]; then 
        echo " there is a problem to generate ansible inventory file for kubespray"
        exit 
fi
if [ ! -f "kubespray/inventory/mycluster/inventory-old.ini"]; then
    echo "the old version of inventory protected"
    mv ../kubespray/inventory/mycluster/inventory.ini ../kubespray/inventory/mycluster/inventory-old.ini
fi

cp inventory.ini ../kubespray/inventory/mycluster/inventory.ini
if [[ $? -eq 1 ]]; then 
        echo " there is a problem to copy generated inventory file fo kubespray " 
        exit 
fi
echo " Setup Kubernetes on provisioned Virtual machines"
ansible-playbook -i ../kubespray/inventory/mycluster/inventory.ini  -b ../kubespray/cluster.yml -kK
if [[ $? -eq 1 ]]; then 
        echo " there is a problem to setup kubernetes Cluster on provisioned vms " 
        exit 
fi