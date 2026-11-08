
# #!/usr/bin/env bash
# set -Eeuo pipefail

# ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# cd "$ROOT"


# BACKUP_DIR="$(cygpath -am "$ROOT/config-backup")"
# TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
# ARCHIVE="openclaw-state-${TIMESTAMP}.tar.gz"

# mkdir -p "$BACKUP_DIR"

# echo "===================================="
# echo " OpenClaw - Backup"
# echo "===================================="

# # Arrêt propre du Gateway
# docker compose stop openclaw-gateway

# # Toujours redémarrer le Gateway après la sauvegarde
# restart_gateway() {
#   docker compose start openclaw-gateway >/dev/null 2>&1 || true
# }
# trap restart_gateway EXIT

# echo "Creating archive: $ARCHIVE"

# MSYS_NO_PATHCONV=1 docker run --rm \
#   --mount type=volume,source=openclaw-state,target=/data,readonly \
#   --mount "type=bind,source=${BACKUP_DIR},target=/backup" \
#   alpine:3.20 \
#   tar czf "/backup/${ARCHIVE}" -C /data .

# # Sauvegarde des secrets et paramètres de déploiement
# if [[ -f .env ]]; then
#   cp .env "${BACKUP_DIR}/.env-${TIMESTAMP}"
# fi

# echo "Removing backups older than 30 days..."

# find "$BACKUP_DIR" -type f \
#   \( -name 'openclaw-state-*.tar.gz' -o -name '.env-*' \) \
#   -mtime +30 -delete

# echo
# echo "Backup completed successfully."
# echo "Location: ${BACKUP_DIR}/${ARCHIVE}"




#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

BACKUP_DIR="$(cygpath -am "$ROOT/config-backup")"
TIMESTAMP="$(date +%Y-%m-%d_%H-%M-%S)"
ARCHIVE="openclaw-state-${TIMESTAMP}.tar.gz"

mkdir -p "$BACKUP_DIR"

WAS_RUNNING=false

if [[ -n "$(docker compose ps --status running -q openclaw-gateway)" ]]; then
  WAS_RUNNING=true
fi

restart_gateway() {
  if [[ "$WAS_RUNNING" == true ]]; then
    docker compose start openclaw-gateway >/dev/null 2>&1 || true
  fi
}

trap restart_gateway EXIT

echo "Stopping Gateway..."
docker compose stop openclaw-gateway

echo "Creating backup..."

MSYS_NO_PATHCONV=1 docker run --rm \
  --mount type=volume,source=openclaw-state,target=/data,readonly \
  --mount "type=bind,source=${BACKUP_DIR},target=/backup" \
  alpine:3.20 \
  tar czf "/backup/${ARCHIVE}" -C /data .

if [[ -f .env ]]; then
  cp .env "${BACKUP_DIR}/.env-${TIMESTAMP}"
fi

echo "Cleaning old backups..."

find "$BACKUP_DIR" -type f \
  \( -name 'openclaw-state-*.tar.gz' -o -name '.env-*' \) \
  -mtime +30 -delete

echo
echo "Backup completed!"
echo "Archive: ${ARCHIVE}"
echo "Location: ${BACKUP_DIR}"
