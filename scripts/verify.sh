
#!/usr/bin/env bash
set -Eeuo pipefail

echo "======================================"
echo " OpenClaw - Deployment Verification"
echo "======================================"

echo
echo "[1] Docker version"
docker --version

echo
echo "[2] Docker Compose validation"
docker compose config --quiet

echo
echo "[3] Docker volume"
docker volume inspect openclaw-state

echo
echo "[4] Containers"
docker compose ps

echo
echo "[5] OpenClaw Gateway logs"
docker compose logs --tail=30 openclaw-gateway

echo
echo "[6] OpenClaw status"
docker compose run --rm openclaw-cli status

echo
echo "Verification completed."
