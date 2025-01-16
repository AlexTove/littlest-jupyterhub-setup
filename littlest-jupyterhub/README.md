# TLJH Setup and Configuration Scripts

This provides scripts to set up and configure your [The Littlest JupyterHub (TLJH)](https://tljh.jupyter.org/) environment. It includes three main scripts:

- `install_dependencies.sh`: Installs necessary Python packages and system-level dependencies.
- `config_auth.sh`: Configures authentication for JupyterHub, supporting both native and OAuth methods.
- `install.sh`: Set up TLJS and configure it to start at system startup.

## Configuration

### .env File
Before running the scripts, customize the `.env` file to reflect your desired configuration:

```ini
# The Littlest Jupyterhub configurations

# Admin credentials
ADMIN_USER="admin"
ADMIN_PASSWORD="admin1234"

# Authentication setup configuration
# Set AUTH_TYPE to "native" for built-in user management
# or "oauth" for OAuth-based authentication
AUTH_TYPE="native"

# User whitelist configuration 
# Set OPEN_SIGNUP to "false" to disable open signup (requires admin approval)
OPEN_SIGNUP="false"

# For OAuth configuration (only needed if AUTH_TYPE is set to "oauth")
OAUTH_CLIENT_ID=""          # Your OAuth Client ID
OAUTH_CLIENT_SECRET=""      # Your OAuth Client Secret
OAUTH_URL=""                # Your OAuth Provider URL (base URL)
```

AUTH_TYPE: Determines which authentication method to use.
- "native": Uses JupyterHub's native authentication mechanism.
- "oauth": Uses an external OAuth provider for authentication. 


## Installation of Dependencies
The install_dependencies script updates your system, activates the base Conda environment, and installs PyTorch along with other Python packages based on the detected CUDA version. It also installs additional utilities needed for JupyterHub.


## Running the Scripts
1. **Ensure .env is correctly configured.**

2. **Make Scripts Executable:**
   ```bash
   chmod +x install_dependencies.sh config_auth.sh
3. **Run install_dependencies:**
   ```bash
   ./install_dependencies.sh
4. **Run config_auth.sh:**
   ```bash
    ./config_auth.sh
