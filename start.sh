#!/bin/bash

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

export $(cat ./.env | awk '!/^\s*#/' | awk '!/^\s*$/' | xargs)

# Install prerequisites

# Install Vagrant
echo "Installing Vagrant..."
wget -O - https://apt.releases.hashicorp.com/gpg 2>/dev/null | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vagrant

# Install VirtualBox
echo "Installing VirtualBox..."
sudo apt install virtualbox

# Start Vagrant
cd vagrant-nfs
vagrant up

cd ../vagrant
vagrant up