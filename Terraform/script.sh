#!/bin/bash

# Update package lists
apt update

# Install necessary dependencies
apt install -y software-properties-common

# Add Ansible repository
apt-add-repository --yes --update ppa:ansible/ansible

# Install Ansible
apt install -y ansible

# Display Ansible version
ansible --version

echo "Ansible has been successfully installed."

cd /tmp
ls
ansible-playbook -i localhost deploy.yaml --ssh-extra-args='-o StrictHostKeyChecking=no'
echo "Ansible Playbook Executed Successully !!!"