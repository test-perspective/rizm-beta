#!/bin/bash
set -e

MODE="${1:-local}"
DOMAIN="${2:-}"
EMAIL="${3:-}"
API_IMAGE="${4:-}"
WEB_IMAGE="${5:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "========================================"
echo "Rizm Beta - Linux Setup"
echo "========================================"
echo ""

# Check if running as root (we'll use sudo for specific commands)
if [ "$EUID" -eq 0 ]; then
  echo "ERROR: Do not run this script as root. It will use sudo when needed." >&2
  exit 1
fi

# Check/Install Docker Engine
echo "[1/5] Checking Docker Engine..." >&2
if command -v docker >/dev/null 2>&1; then
  if docker version >/dev/null 2>&1; then
    echo "  OK: Docker is installed and running" >&2
  else
    echo "  Docker command found but not responding. Checking service..." >&2
    sudo systemctl start docker || true
  fi
else
  echo "  Installing Docker Engine..." >&2
  
  # Detect distribution
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
  else
    echo "ERROR: Cannot detect Linux distribution" >&2
    exit 1
  fi
  
  if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    # Ubuntu/Debian installation
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/$OS/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$OS \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    sudo systemctl enable --now docker
    sudo usermod -aG docker "$USER"
    
    echo "  Docker Engine installed. You may need to log out and log back in for group changes to take effect." >&2
  else
    echo "ERROR: Unsupported Linux distribution: $OS" >&2
    echo "  Please install Docker manually: https://docs.docker.com/engine/install/" >&2
    exit 1
  fi
fi

# Wait for Docker to be ready
echo ""
echo "[2/5] Waiting for Docker to be ready..." >&2
MAX_WAIT=60
WAITED=0

# Prefer plain docker, but fall back to sudo docker when the user
# doesn't have permission to access the Docker socket yet.
DOCKER_CMD="docker"

docker_version_ok() {
  docker version >/dev/null 2>&1
}

sudo_docker_version_ok() {
  sudo -n docker version >/dev/null 2>&1
}

while [ $WAITED -lt $MAX_WAIT ]; do
  if docker_version_ok; then
    DOCKER_CMD="docker"
    echo "  OK: Docker is ready" >&2
    break
  fi

  # If docker is installed but the current user can't access the socket,
  # sudo docker may work (common right after installation / before re-login).
  if sudo_docker_version_ok; then
    DOCKER_CMD="sudo docker"
    echo "  OK: Docker is ready (using sudo)" >&2
    echo "  Note: You may need to log out and log back in for docker group changes to take effect." >&2
    break
  fi

  sleep 2
  WAITED=$((WAITED + 2))
  echo "  Waiting... ($WAITED/$MAX_WAIT seconds)" >&2
done

if [ $WAITED -ge $MAX_WAIT ]; then
  echo "ERROR: Docker did not become ready within $MAX_WAIT seconds" >&2
  echo "  Try:" >&2
  echo "    sudo systemctl start docker" >&2
  echo "    sudo systemctl status docker --no-pager" >&2
  echo "    sudo journalctl -u docker --no-pager -n 200" >&2
  exit 1
fi

# Check Docker Compose plugin
echo ""
echo "[3/5] Checking Docker Compose..." >&2
if $DOCKER_CMD compose version >/dev/null 2>&1; then
  echo "  OK: Docker Compose plugin found" >&2
else
  echo "ERROR: Docker Compose plugin not found" >&2
  echo "  Please install docker-compose-plugin" >&2
  exit 1
fi

# Prepare .env
echo ""
echo "[4/5] Preparing .env file..." >&2
ENV_PATH="$REPO_ROOT/.env"
ENV_EXAMPLE_PATH="$REPO_ROOT/.env.example"

if [ ! -f "$ENV_PATH" ]; then
  if [ -f "$ENV_EXAMPLE_PATH" ]; then
    cp "$ENV_EXAMPLE_PATH" "$ENV_PATH"
    echo "  Created .env from .env.example" >&2
  else
    echo "  WARNING: .env.example not found. Creating minimal .env..." >&2
    cat > "$ENV_PATH" <<EOF
RIZM_API_IMAGE=kabekenputer/keel-api:latest
RIZM_WEB_IMAGE=kabekenputer/keel-web:latest
KEEL_BOOTSTRAP_ADMIN_EMAIL=admin@example.local
KEEL_BOOTSTRAP_ADMIN_PASSWORD=change-this-password
KEEL_COOKIE_SECURE=false
KEEL_CSRF_ALLOWED_ORIGIN=http://localhost:8080
EOF
  fi
else
  echo "  .env already exists, skipping" >&2
fi

# Override image settings if provided
if [ -n "$API_IMAGE" ]; then
  sed -i "s|^RIZM_API_IMAGE=.*|RIZM_API_IMAGE=$API_IMAGE|" "$ENV_PATH"
fi
if [ -n "$WEB_IMAGE" ]; then
  sed -i "s|^RIZM_WEB_IMAGE=.*|RIZM_WEB_IMAGE=$WEB_IMAGE|" "$ENV_PATH"
fi

# Domain mode: set domain and email
if [ "$MODE" = "domain" ]; then
  if [ -z "$DOMAIN" ]; then
    echo "ERROR: Domain is required for domain mode" >&2
    exit 1
  fi
  if [ -z "$EMAIL" ]; then
    echo "ERROR: Email is required for domain mode" >&2
    exit 1
  fi
  
  sed -i "s|^APP_DOMAIN=.*|APP_DOMAIN=$DOMAIN|" "$ENV_PATH"
  sed -i "s|^LETSENCRYPT_EMAIL=.*|LETSENCRYPT_EMAIL=$EMAIL|" "$ENV_PATH"
  sed -i "s|^KEEL_COOKIE_SECURE=.*|KEEL_COOKIE_SECURE=true|" "$ENV_PATH"
  
  if ! grep -q "^APP_DOMAIN=" "$ENV_PATH"; then
    echo "APP_DOMAIN=$DOMAIN" >> "$ENV_PATH"
  fi
  if ! grep -q "^LETSENCRYPT_EMAIL=" "$ENV_PATH"; then
    echo "LETSENCRYPT_EMAIL=$EMAIL" >> "$ENV_PATH"
  fi
  
  echo "  Configured for domain mode: $DOMAIN" >&2
fi

# Local mode: allow CSRF for localhost
if [ "$MODE" = "local" ]; then
  if ! grep -q "^KEEL_CSRF_ALLOWED_ORIGIN=" "$ENV_PATH"; then
    echo "KEEL_CSRF_ALLOWED_ORIGIN=http://localhost:8080" >> "$ENV_PATH"
  fi
fi

# Start Docker Compose
echo ""
echo "[5/5] Starting Rizm with Docker Compose..." >&2

cd "$REPO_ROOT"

# Use a relative compose path so Docker Compose treats the repo root as the project directory
# (ensures ./.env is used for ${...} variable interpolation).
COMPOSE_FILE="compose/docker-compose.$MODE.yml"

$DOCKER_CMD compose --env-file "$ENV_PATH" -f "$COMPOSE_FILE" pull || echo "WARNING: docker compose pull failed, continuing anyway..." >&2

$DOCKER_CMD compose --env-file "$ENV_PATH" -f "$COMPOSE_FILE" up -d

if [ $? -ne 0 ]; then
  echo "ERROR: Failed to start containers" >&2
  exit 1
fi

echo ""
echo "========================================"
echo "Rizm is starting!"
echo "========================================"
echo ""

if [ "$MODE" = "local" ]; then
  echo "Access Rizm at: http://localhost:8080"
else
  echo "Access Rizm at: https://$DOMAIN"
  echo "  (SSL certificate may take a few minutes to be issued)"
fi

echo ""
echo "Default admin credentials:"
echo "  Email: admin@example.local"
echo "  Password: change-this-password"
echo ""
echo "To check status: $DOCKER_CMD compose --env-file $ENV_PATH -f $COMPOSE_FILE ps"
echo "To view logs: $DOCKER_CMD compose --env-file $ENV_PATH -f $COMPOSE_FILE logs -f"
echo "To stop: $DOCKER_CMD compose --env-file $ENV_PATH -f $COMPOSE_FILE down"
