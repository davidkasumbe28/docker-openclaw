#!/usr/bin/env bash

set -e


echo "===================================="
echo " OpenClaw Deployment"
echo " Linux + Docker"
echo "===================================="

# Répertoire du script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

APP_DIR="$SCRIPT_DIR/.." 

IMAGE="ghcr.io/openclaw/openclaw:latest"

TIMEZONE="Africa/Kinshasa"

GEMINI_MODEL_DEFAULT=gemini-3.1-flash-lite


# -------------------------------
# Docker check
# -------------------------------

if ! command -v docker >/dev/null
then

    echo "Docker absent"

    sudo ./install-docker.sh

    echo "Relancez le script après reconnexion"
    echo "Installer Docker et relancez le script"

    exit 0

fi



docker compose version



# -------------------------------
# Directory
# -------------------------------


echo "[1/6] Creation dossier"


mkdir -p \
$APP_DIR/data

cd $APP_DIR/data

cat > openclaw.json <<EOF

{
  "agents": {
    "defaults": {
      "model": {
        "primary": "google/gemini-3.1-flash-lite"
      }
    },
    "auth": {
      "profiles": {
        "google:default": {
          "provider": "google",
          "mode": "api_key"
        }
      }
    }
  }
}

EOF


cd $APP_DIR


# -------------------------------
# Token
# -------------------------------


echo "[2/6] Generation token"


TOKEN=$(openssl rand -hex 32)


# -------------------------------
# Environment
# -------------------------------


echo "[3/6] Creation .env"


read -p "Entrez votre clé api gemini : " GEMINI_API_KEY
GEMINI_API_KEY=${GEMINI_API_KEY:-COLLER_VOTRE_CLE_ICI}

read -p "Entrez le modele gemini : " GEMINI_MODEL
GEMINI_MODEL=${GEMINI_MODEL:-gemini-3.1-flash-lite}

cat > .env <<EOF

OPENCLAW_GATEWAY_TOKEN=$TOKEN

GEMINI_API_KEY=$GEMINI_API_KEY

GEMINI_MODEL=$GEMINI_MODEL

EOF


# -------------------------------
# Compose
# -------------------------------


echo "[4/6] Creation compose"


read -p "Entrez le nom du conteneur gateway (par défaut: openclaw-gateway): " CONTAINER_GATEWAY_NAME
CONTAINER_GATEWAY_NAME=${CONTAINER_GATEWAY_NAME:-openclaw-gateway}

read -p "Entrez le nom du conteneur cli (par défaut: openclaw-cli): " CONTAINER_CLI_NAME
CONTAINER_CLI_NAME=${CONTAINER_CLI_NAME:-openclaw-cli}


cat > docker-compose.yml <<EOF

services:
  openclaw:
    image: $IMAGE
    container_name: $CONTAINER_GATEWAY_NAME
    restart: unless-stopped

    environment:
      TZ: $TIMEZONE

      # Sécurité Gateway
      OPENCLAW_GATEWAY_TOKEN: \${OPENCLAW_GATEWAY_TOKEN}

      # Gemini
      GEMINI_API_KEY: \${GEMINI_API_KEY}

      # Configuration OpenClaw
      OPENCLAW_CONFIG_JSON: |
        {
          "agents": {
            "defaults": {
              "model": {
                "primary": ${GEMINI_MODEL}
              }
            }
          },
          "auth": {
            "profiles": {
              "google:default": {
                  "provider": "google",
                  "mode": "api_key"
              }
            }
          }
        }

    ports:
      - "18789:18789"

    volumes:
      - ./data:/home/node/.openclaw
      - ./plugins:/home/node/.openclaw/plugins

    command:
      - node
      - openclaw.mjs
      - gateway
      - --allow-unconfigured

  openclaw-cli:
    image: $IMAGE
    container_name: $CONTAINER_CLI_NAME

    env_file:
      - .env

    volumes:
      - ./data:/home/node/.openclaw
      - ./plugins:/home/node/.openclaw/plugins

    network_mode: "service:openclaw"


EOF



# -------------------------------
# Start
# -------------------------------


echo "[5/6] Demarrage OpenClaw"


docker compose pull

docker compose up -d


# -------------------------------
# Status
# -------------------------------


echo "[6/6] Verification"


sleep 10


docker ps


echo ""
echo "===================================="
echo " OpenClaw actif"
echo "===================================="


echo ""

echo "Dashboard:"
echo ""

echo "http://127.0.0.1:18789/#token=$TOKEN"

echo ""

echo "Modifier : .env si possible"
echo "$APP_DIR/.env"
