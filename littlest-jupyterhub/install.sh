#!/bin/bash
set -e

parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$parent_path"

# Load configured variables

export $(cat ./.env | awk '!/^\s*#/' | awk '!/^\s*$/' | xargs)

# 1. Update system and install prerequisites

echo "Installing The Littlest JupyterHub prerequisites..."
sudo apt --assume-yes install python3 python3-dev git curl

# 2. Install TLJH

echo "Installing The Littlest JupyterHub..."
curl -L https://tljh.jupyter.org/bootstrap.py | sudo python3 - --admin "$ADMIN_USER":"$ADMIN_PASSWORD"

# 3. Configure authentication

# Set up native authentication
echo "Setting up native authentication..."
sudo tljh-config set auth.NativeAuthenticator.allow_all true
sudo tljh-config set auth.type nativeauthenticator.NativeAuthenticator
sudo tljh-config set auth.NativeAuthenticator.open_signup false

# Reload configurations after setting authentication
sudo tljh-config reload

# 4. Install additional python packages that will be available for all users

echo "Installing additional Python packages..."
sudo -E pip install --no-cache-dir -r requirements.txt

# 6. Create a shared data folder where an admin can add utility files that will be available for new users
# as read-only.

echo "Creating shared folder..."
sudo mkdir -p /srv/data/shared_data
cd /etc/skel
sudo ln -s /srv/data/shared_data shared_data

# (Optional) Download data into /srv/data/my_shared_data_folder
