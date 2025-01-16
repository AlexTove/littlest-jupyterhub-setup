#!/bin/bash
set -e

export $(cat ./.env | awk '!/^\s*#/' | awk '!/^\s*$/' | xargs)

if [ "$AUTH_TYPE" == "native" ]; then
    echo "Configuring native authentication..."
    sudo tljh-config set auth.type nativeauthenticator.NativeAuthenticator
    sudo tljh-config set auth.NativeAuthenticator.open_signup "$OPEN_SIGNUP"
    sudo tljh-config reload
else
    echo "OAuth selected."
    # Prompt for OAuth parameters if not set in environment
    [ -z "$OAUTH_CLIENT_ID" ] && read -p "Enter OAuth Client ID: " OAUTH_CLIENT_ID
    [ -z "$OAUTH_CLIENT_SECRET" ] && read -p "Enter OAuth Client Secret: " OAUTH_CLIENT_SECRET
    [ -z "$OAUTH_URL" ] && read -p "Enter OAuth Userdata URL: " OAUTH_USERDATA_URL

    echo "Configuring OAuth authentication..."
    OAUTH_CONFIG_DIR="/opt/tljh/config/jupyterhub_config.d"
    OAUTH_CONFIG_FILE="$OAUTH_CONFIG_DIR/oauth_config.py"
    sudo mkdir -p "$OAUTH_CONFIG_DIR"

    sudo bash -c "cat <<EOF > $OAUTH_CONFIG_FILE
      c = get_config()  # noqa

      c.JupyterHub.authenticator_class = "generic-oauth"

      provider = "$OAUTH_URL"
      c.GenericOAuthenticator.authorize_url = f"{provider}/authorize"
      c.GenericOAuthenticator.token_url = f"{provider}/token"
      c.GenericOAuthenticator.userdata_url = f"{provider}/userinfo"
      c.GenericOAuthenticator.scope = ["openid"]

      c.GenericOAuthenticator.client_id = "$OAUTH_CLIENT_ID"
      c.GenericOAuthenticator.client_secret = "$OAUTH_CLIENT_SECRET"

      c.GenericOAuthenticator.username_claim = "sub"

      c.GenericOAuthenticator.allow_all = True
      c.GenericOAuthenticator.admin_users = {"$ADMIN_USER"}

      c.JupyterHub.default_url = "/hub/home"
      c.JupyterHub.spawner_class = "simple"
      c.JupyterHub.ip = "127.0.0.1"
      EOF"

    sudo tljh-config set auth.type 'oauthenticator.generic.GenericOAuthenticator'
    sudo tljh-config reload
fi

echo "Authentication configuration complete."
