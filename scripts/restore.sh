
# #!/usr/bin/env bash
# set -Eeuo pipefail

# ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# cd "$ROOT"

# BACKUP_DIR="$ROOT/config-backup"

# echo "============================================"
# echo "       OpenClaw - Restore Manager"
# echo "============================================"
# echo

# # Vérification du dossier de sauvegarde
# if [[ ! -d "$BACKUP_DIR" ]]; then
#     echo "ERROR: Backup directory not found:"
#     echo "$BACKUP_DIR"
#     exit 1
# fi

# # Recherche des archives disponibles
# mapfile -t BACKUPS < <(
#     find "$BACKUP_DIR" -maxdepth 1 -type f \
#         -name 'openclaw-state-*.tar.gz' \
#         -printf '%f\n' | sort -r
# )

# if [[ ${#BACKUPS[@]} -eq 0 ]]; then
#     echo "No backup archives found."
#     exit 1
# fi

# echo "Available backups:"
# echo

# for i in "${!BACKUPS[@]}"; do
#     printf " [%d] %s\n" "$((i+1))" "${BACKUPS[$i]}"
# done

# echo
# echo "============================================"
# echo " Choose restoration method"
# echo "============================================"
# echo
# echo " [1] Enter a backup filename or path"
# echo " [2] Restore the latest backup automatically"
# echo

# read -r -p "Your choice [1/2]: " CHOICE

# case "$CHOICE" in
#     1)
#         echo
#         read -r -p "Enter backup filename or path: " SELECTED

#         if [[ "$SELECTED" = /* || "$SELECTED" =~ ^[A-Za-z]:[/\\] ]]; then
#             ARCHIVE="$SELECTED"
#         elif [[ -f "$SELECTED" ]]; then
#             ARCHIVE="$SELECTED"
#         else
#             ARCHIVE="$BACKUP_DIR/$SELECTED"
#         fi
#         ;;

#     2)
#         ARCHIVE="$BACKUP_DIR/${BACKUPS[0]}"
#         echo
#         echo "Latest backup selected:"
#         echo "${BACKUPS[0]}"
#         ;;

#     *)
#         echo "Invalid choice."
#         exit 1
#         ;;
# esac

# # Vérifier l'archive
# if [[ ! -f "$ARCHIVE" ]]; then
#     echo
#     echo "ERROR: Backup archive not found:"
#     echo "$ARCHIVE"
#     exit 1
# fi

# ARCHIVE="$(cygpath -am "$ARCHIVE")"
# BACKUP_PATH="$(cygpath -am "$(dirname "$ARCHIVE")")"
# ARCHIVE_NAME="$(basename "$ARCHIVE")"

# echo
# echo "Selected backup:"
# echo "$ARCHIVE_NAME"
# echo

# # Vérifier l'intégrité de l'archive
# echo "Checking archive integrity..."

# MSYS_NO_PATHCONV=1 docker run --rm \
#     --mount "type=bind,source=${BACKUP_PATH},target=/backup,readonly" \
#     alpine:3.20 \
#     tar tzf "/backup/${ARCHIVE_NAME}" >/dev/null

# echo "Archive integrity: OK"

# echo
# echo "WARNING: Current OpenClaw data will be replaced."
# echo "A backup of the current state is strongly recommended."
# echo

# read -r -p "Confirm restoration? Type YES: " CONFIRM

# if [[ "$CONFIRM" != "YES" ]]; then
#     echo "Restoration cancelled."
#     exit 0
# fi

# # Arrêter les services
# echo
# echo "[1/4] Stopping OpenClaw..."

# docker compose down

# # Créer le volume s'il n'existe pas
# echo "[2/4] Preparing Docker volume..."

# docker volume create openclaw-state >/dev/null

# # Restaurer les données
# echo "[3/4] Restoring OpenClaw data..."

# MSYS_NO_PATHCONV=1 docker run --rm \
#     --mount type=volume,source=openclaw-state,target=/data \
#     --mount "type=bind,source=${BACKUP_PATH},target=/backup,readonly" \
#     alpine:3.20 sh -c "
#         find /data -mindepth 1 -maxdepth 1 -exec rm -rf {} +
#         tar xzf '/backup/${ARCHIVE_NAME}' -C /data
#         chown -R 1000:1000 /data
#     "

# # Restaurer le .env correspondant
# TIMESTAMP="${ARCHIVE_NAME#openclaw-state-}"
# TIMESTAMP="${TIMESTAMP%.tar.gz}"

# ENV_BACKUP="$BACKUP_DIR/.env-${TIMESTAMP}"

# if [[ -f "$ENV_BACKUP" ]]; then
#     cp "$ENV_BACKUP" .env
#     echo "Environment file restored."
# else
#     echo "WARNING: Matching .env backup not found."
#     echo "Current .env has been preserved."
# fi

# # Redémarrer OpenClaw
# echo "[4/4] Starting OpenClaw..."

# docker compose up -d openclaw-gateway

# echo
# echo "============================================"
# echo "       RESTORATION COMPLETED"
# echo "============================================"
# echo
# echo "Restored archive: $ARCHIVE_NAME"
# echo
# docker compose ps

# echo
# echo "Check logs with:"
# echo "docker compose logs -f openclaw-gateway"




#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

BACKUP_DIR="$ROOT/config-backup"

echo "============================================"
echo "         OpenClaw - Restore Manager"
echo "============================================"
echo

if [[ ! -d "$BACKUP_DIR" ]]; then
  echo "ERROR: Backup directory not found."
  exit 1
fi

mapfile -t BACKUPS < <(
  find "$BACKUP_DIR" -maxdepth 1 -type f \
    -name 'openclaw-state-*.tar.gz' \
    -printf '%f\n' | sort -r
)

if [[ ${#BACKUPS[@]} -eq 0 ]]; then
  echo "No backup archives found."
  exit 1
fi

echo "Available backups:"
echo

for i in "${!BACKUPS[@]}"; do
  printf " [%d] %s\n" "$((i+1))" "${BACKUPS[$i]}"
done

echo
echo "[1] Enter a backup filename or path"
echo "[2] Restore the latest backup"
echo

read -r -p "Your choice [1/2]: " CHOICE

case "$CHOICE" in
  1)
    read -r -p "Backup filename or path: " SELECTED

    if [[ "$SELECTED" =~ ^[A-Za-z]:[/\\] ]] ||
       [[ "$SELECTED" = /* ]]; then
      ARCHIVE="$SELECTED"
    elif [[ -f "$SELECTED" ]]; then
      ARCHIVE="$SELECTED"
    else
      ARCHIVE="$BACKUP_DIR/$SELECTED"
    fi
    ;;

  2)
    ARCHIVE="$BACKUP_DIR/${BACKUPS[0]}"
    echo "Selected: ${BACKUPS[0]}"
    ;;

  *)
    echo "Invalid choice."
    exit 1
    ;;
esac

if [[ ! -f "$ARCHIVE" ]]; then
  echo "ERROR: Backup archive not found."
  exit 1
fi

ARCHIVE="$(cygpath -am "$ARCHIVE")"
BACKUP_PATH="$(cygpath -am "$(dirname "$ARCHIVE")")"
ARCHIVE_NAME="$(basename "$ARCHIVE")"

echo
echo "Checking archive integrity..."

MSYS_NO_PATHCONV=1 docker run --rm \
  --mount "type=bind,source=${BACKUP_PATH},target=/backup,readonly" \
  alpine:3.20 \
  tar tzf "/backup/${ARCHIVE_NAME}" >/dev/null

echo "Archive integrity: OK"

echo
echo "WARNING: Current OpenClaw data will be replaced."
echo

read -r -p "Type YES to confirm restoration: " CONFIRM

if [[ "$CONFIRM" != "YES" ]]; then
  echo "Restore cancelled."
  exit 0
fi

echo
echo "[1/4] Stopping OpenClaw..."
docker compose down

echo "[2/4] Preparing Docker volume..."
docker volume create openclaw-state >/dev/null

echo "[3/4] Restoring data..."

MSYS_NO_PATHCONV=1 docker run --rm \
  --mount type=volume,source=openclaw-state,target=/data \
  --mount "type=bind,source=${BACKUP_PATH},target=/backup,readonly" \
  alpine:3.20 sh -c "
    find /data -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    tar xzf '/backup/${ARCHIVE_NAME}' -C /data
    chown -R 1000:1000 /data
  "

TIMESTAMP="${ARCHIVE_NAME#openclaw-state-}"
TIMESTAMP="${TIMESTAMP%.tar.gz}"

ENV_BACKUP="$BACKUP_DIR/.env-${TIMESTAMP}"

if [[ -f "$ENV_BACKUP" ]]; then
  cp "$ENV_BACKUP" .env
  echo "Environment restored."
else
  echo "WARNING: Matching .env backup not found."
  echo "Current .env preserved."
fi

echo "[4/4] Starting Gateway..."

docker compose up -d openclaw-gateway

echo
echo "============================================"
echo "       RESTORE COMPLETED"
echo "============================================"

docker compose ps

echo
echo "Logs: docker compose logs -f openclaw-gateway"
