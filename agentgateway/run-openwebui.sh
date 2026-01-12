#docker run -d -p 9999:8080 -v ~/temp/open-webui:/app/backend/data \
#--env-file ./openweb-ui/env \
#--name open-webui ghcr.io/open-webui/open-webui:v0.6.33

# A virtual env needs to be enabled, but we won't script this for now
# source .venv/bin/activate
# source .venv-desktop/bin/activate

# set up localhost OIDC
export WEBUI_URL=http://localhost:9999
export OAUTH_CLIENT_ID=openweb-ui
export OAUTH_CLIENT_SECRET=xvOT8QntENYS7ABv1MMxqJzDXWf55Fuc
export OAUTH_PROVIDER_NAME=Keycloak
export OPENID_PROVIDER_URL=http://localhost:8080/realms/mcp-realm/.well-known/openid-configuration
export OAUTH_SCOPES=openid email profile
export ENABLE_OAUTH_SIGNUP=true
export OAUTH_MERGE_ACCOUNTS_BY_EMAIL=true
export OPENID_REDIRECT_URI=http://localhost:9999/oauth/oidc/callback
export LOG_LEVEL=debug

# CRITICAL: Add these for OAuth token storage
export WEBUI_SECRET_KEY="mysecretkeythatisverylong1234567890"
export OAUTH_SESSION_TOKEN_ENCRYPTION_KEY="mysecretkeythatisverylong1234567890"

# Optional but recommended
export ENABLE_OAUTH_ID_TOKEN_COOKIE=true
# Run it
open-webui serve --port 9999