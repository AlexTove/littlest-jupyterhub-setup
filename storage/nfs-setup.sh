#!/bin/bash
set -e

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

# Install prerequisites

sudo apt install nfs-kernel-server -y

# Create export directory

sudo mkdir -p /srv/nfs
sudo chmod 777 /srv/nfs

sudo rm /etc/exports
sudo cp /storage/exports /etc/exports

# Apply new config.

sudo exportfs -a

# Start NFS

sudo systemctl restart nfs-kernel-server.service
