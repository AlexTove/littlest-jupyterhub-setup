#!/bin/bash
set -e

# Function to check CUDA version
get_cuda_version() {
    if command -v nvcc &> /dev/null; then
        nvcc --version | grep -oP 'release \K[0-9]+\.[0-9]+'
    else
        echo "none"
    fi
}

echo "Updating system and installing prerequisites..."
sudo apt-get update

# Activate base Conda environment from TLJH
echo "Activating base Conda environment..."
source /opt/tljh/user/bin/activate

# Conditional Installation of PyTorch and Related Packages
echo "Checking if PyTorch is already installed..."
if ! pip list | grep -q "torch\|torchvision\|torchaudio"; then
    echo "PyTorch not found. Proceeding with installation..."

    # Determine CUDA version
    CUDA_VERSION=$(get_cuda_version)
    echo "Detected CUDA version: $CUDA_VERSION"

    # Install PyTorch based on CUDA version
    if [[ "$CUDA_VERSION" == "12.4" ]]; then
        echo "Installing PyTorch for CUDA 12.4..."
        pip install --no-cache-dir torch torchvision torchaudio
    elif [[ "$CUDA_VERSION" == "12.1" ]]; then
        echo "Installing PyTorch for CUDA 12.1..."
        pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    elif [[ "$CUDA_VERSION" == "11.8" ]]; then
        echo "Installing PyTorch for CUDA 11.8..."
        pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    else
        echo "No recognized CUDA version detected. Installing CPU-only PyTorch..."
        pip install --no-cache-dir torch torchvision torchaudio
    fi

fi

echo "Installing additional packages..."
sudo -E pip install --no-cache-dir -r requirements.txt

# Uncomment for R kernel installation if needed
# apt-get install -y r-base
# sudo R -e "install.packages('IRkernel', repos='https://cloud.r-project.org/')"
# sudo R -e "IRkernel::installspec(name = 'ir', displayname = 'R')"

echo "Installation of dependencies complete."
