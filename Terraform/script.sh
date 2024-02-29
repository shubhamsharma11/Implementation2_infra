#!/bin/bash

# Update package lists
sudo apt update

# Install necessary dependencies
sudo apt install -y software-properties-common

# Add Ansible repository
sudo apt-add-repository --yes --update ppa:ansible/ansible

# Install Ansible
sudo apt install -y ansible

# Display Ansible version
ansible --version

echo "Ansible has been successfully installed."

cd /tmp
ls
ansible-playbook -i localhost deploy.yaml --ssh-extra-args='-o StrictHostKeyChecking=no'
echo "Ansible Playbook Executed Successully !!!"

echo "Azure self hosted agent installation started."
mkdir myagent && cd myagent
wget -O vsts-agent-linux-x64-3.234.0.tar.gz https://vstsagentpackage.azureedge.net/agent/3.234.0/vsts-agent-linux-x64-3.234.0.tar.gz
tar zxvf vsts-agent-linux-x64-3.234.0.tar.gz
./config.sh --unattended --url https://dev.azure.com/Shubham1708698304552/ --auth pat --token x4x4wzwy7w53ikj54ipzhbnmjjnfohcewotpag7zx27ugkgusqmq --pool Default --agent LinuxAgent01 --acceptTeeEula --replace
echo "Azure self hosted agent installation successful."
