set -e

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$parent_path"

# Install nfs client

sudo apt install nfs-common -y

# Set up nfs

sudo mkdir -p /mnt/nfs
# Backup home.
sudo mkdir -p /temphome
sudo mv /home/* /temphome
sudo mount -t nfs 192.168.100.202:/srv/nfs /home
sudo mv /temphome/* /home