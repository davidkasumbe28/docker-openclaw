
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

echo "======================================"
echo " OpenClaw Gemini Docker Installer"
echo "======================================"

command -v docker >/dev/null 2>&1 || {
  echo "ERROR: Docker is not installed."
  exit 1
}

docker compose version >/dev/null 2>&1 || {
  echo "ERROR: Docker Compose v2 is required."
  exit 1
}

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env. Configure your credentials."
  exit 1
fi

set -a
source .env
set +a

if [[ -z "${GEMINI_API_KEY:-}" ||
      "$GEMINI_API_KEY" == "YOUR_GEMINI_API_KEY" ]]; then
  echo "ERROR: Configure GEMINI_API_KEY."
  exit 1
fi

if [[ -z "${OPENCLAW_GATEWAY_TOKEN:-}" ||
      "$OPENCLAW_GATEWAY_TOKEN" == "CHANGE_ME" ]]; then
  echo "ERROR: Configure OPENCLAW_GATEWAY_TOKEN."
  exit 1
fi

echo "[1/5] Validating Docker Compose..."
docker compose config --quiet

echo "[2/5] Pulling OpenClaw image..."
docker compose pull

echo "[3/5] Creating persistent volume..."
docker volume create openclaw-state >/dev/null

echo "[4/5] Initializing configuration..."

MSYS_NO_PATHCONV=1 docker run --rm \
  -v openclaw-state:/data \
  alpine:3.20 sh -c '
    mkdir -p /data/workspace /data/logs/support
    if [ ! -f /data/openclaw.json ]; then
      cat > /data/openclaw.json <<EOF
{
  "gateway": {
    "mode": "local"
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "google/gemini-3.1-flash-lite"
      }
    }
  }
}
EOF
    fi
    chown -R 1000:1000 /data
  '

echo "[5/5] Starting Gateway..."
docker compose up -d openclaw-gateway

echo
echo "======================================"
echo " Installation completed!"
echo "======================================"
echo
echo "Dashboard: http://127.0.0.1:18789"
echo "Logs: docker compose logs -f openclaw-gateway"
