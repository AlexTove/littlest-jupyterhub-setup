#!/bin/bash
set -e

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$parent_path"

# Install prerequisites and start nfs

sudo apt install nfs-kernel-server -y
sudo systemctl start nfs-kernel-server.service

# Create export directory

sudo mkdir -p /srv/nfs
sudo chmod 777 /srv/nfs

sudo rm /etc/exports
sudo cp /storage/exports /etc/exports

# Apply new config.

sudo exportfs -a


