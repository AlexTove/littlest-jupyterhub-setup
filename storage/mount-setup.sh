#!/bin/bash
set -e

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$parent_path"

shopt -s extglob

# Install nfs client

sudo apt install nfs-common -y

mkdir -p /srv/notebooks

echo "Mounting NFS partition"
sudo mount -t nfs 192.168.50.202:/srv/nfs /srv/notebooks

cp /littlest-jupyterhub/spawner_config.py /opt/tljh/config/jupyterhub_config.d/
sudo tljh-config reload hub