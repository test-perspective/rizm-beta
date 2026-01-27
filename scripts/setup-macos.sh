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
echo "Rizm Beta - macOS Setup"
echo "========================================"
echo ""

# Check/Install Homebrew
echo "[1/5] Checking Homebrew..." >&2
if ! command -v brew >/dev/null 2>&1; then
  echo "  Installing Homebrew..." >&2
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "  OK: Homebrew found" >&2
fi

# Check/Install Docker Desktop
echo ""
echo "[2/5] Checking Docker Desktop..." >&2
if command -v docker >/dev/null 2>&1; then
  if docker version >/dev/null 2>&1; then
    echo "  OK: Docker is installed and running" >&2
  else
    echo "  Docker command found but not responding. Starting Docker Desktop..." >&2
    open -a Docker
  fi
else
  echo "  Installing Docker Desktop via Homebrew..." >&2
  brew install --cask docker
  echo "  Starting Docker Desktop..." >&2
  open -a Docker
fi

# Wait for Docker to be ready
echo ""
echo "[3/5] Waiting for Docker to be ready..." >&2
MAX_WAIT=60
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
  if docker version >/dev/null 2>&1; then
    echo "  OK: Docker is ready" >&2
    break
  fi
  sleep 2
  WAITED=$((WAITED + 2))
  echo "  Waiting... ($WAITED/$MAX_WAIT seconds)" >&2
done

if [ $WAITED -ge $MAX_WAIT ]; then
  echo "ERROR: Docker did not become ready within $MAX_WAIT seconds" >&2
  echo "  Please start Docker Desktop manually and run this script again." >&2
  exit 1
fi

# Check Docker Compose plugin
echo ""
echo "[4/5] Checking Docker Compose..." >&2
if docker compose version >/dev/null 2>&1; then
  echo "  OK: Docker Compose plugin found" >&2
else
  echo "ERROR: Docker Compose plugin not found" >&2
  echo "  Docker Desktop should include it. Please check Docker Desktop installation." >&2
  exit 1
fi

# Prepare .env
echo ""
echo "[5/5] Preparing .env file..." >&2
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
EOF
  fi
else
  echo "  .env already exists, skipping" >&2
fi

# Override image settings if provided
if [ -n "$API_IMAGE" ]; then
  sed -i '' "s|^RIZM_API_IMAGE=.*|RIZM_API_IMAGE=$API_IMAGE|" "$ENV_PATH"
fi
if [ -n "$WEB_IMAGE" ]; then
  sed -i '' "s|^RIZM_WEB_IMAGE=.*|RIZM_WEB_IMAGE=$WEB_IMAGE|" "$ENV_PATH"
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
  
  sed -i '' "s|^APP_DOMAIN=.*|APP_DOMAIN=$DOMAIN|" "$ENV_PATH"
  sed -i '' "s|^LETSENCRYPT_EMAIL=.*|LETSENCRYPT_EMAIL=$EMAIL|" "$ENV_PATH"
  sed -i '' "s|^KEEL_COOKIE_SECURE=.*|KEEL_COOKIE_SECURE=true|" "$ENV_PATH"
  
  if ! grep -q "^APP_DOMAIN=" "$ENV_PATH"; then
    echo "APP_DOMAIN=$DOMAIN" >> "$ENV_PATH"
  fi
  if ! grep -q "^LETSENCRYPT_EMAIL=" "$ENV_PATH"; then
    echo "LETSENCRYPT_EMAIL=$EMAIL" >> "$ENV_PATH"
  fi
  
  echo "  Configured for domain mode: $DOMAIN" >&2
fi

# Start Docker Compose
echo ""
echo "[6/6] Starting Rizm with Docker Compose..." >&2

cd "$REPO_ROOT"

# Use a relative compose path so Docker Compose treats the repo root as the project directory
# (ensures ./.env is used for ${...} variable interpolation).
COMPOSE_FILE="compose/docker-compose.$MODE.yml"

docker compose --env-file "$ENV_PATH" -f "$COMPOSE_FILE" pull || echo "WARNING: docker compose pull failed, continuing anyway..." >&2

docker compose --env-file "$ENV_PATH" -f "$COMPOSE_FILE" up -d

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
echo "To check status: docker compose --env-file $ENV_PATH -f $COMPOSE_FILE ps"
echo "To view logs: docker compose --env-file $ENV_PATH -f $COMPOSE_FILE logs -f"
echo "To stop: docker compose --env-file $ENV_PATH -f $COMPOSE_FILE down"
