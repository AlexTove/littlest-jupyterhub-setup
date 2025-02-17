#!/bin/bash
set -e

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
cd "$parent_path"

shopt -s extglob

# Install nfs client

sudo apt install nfs-common -y

mkdir -p /srv/notebooks

echo "Mounting NFS partition $NFS_VM_IP"
sudo mount -t nfs "$NFS_VM_IP:/srv/nfs" /srv/notebooks

cp /littlest-jupyterhub/spawner_config.py /opt/tljh/config/jupyterhub_config.d/
sudo tljh-config reload hub