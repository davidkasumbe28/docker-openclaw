# OpenClaw Docker

**Déploiement simple et persistant d'OpenClaw avec Docker Compose.**

![OpenClaw](https://img.shields.io/badge/OpenClaw-2026.9.3-blue) ![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white) ![Gemini](https://img.shields.io/badge/AI-Gemini%203.1%20Flash%20Lite-8E75B2) ![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

## Présentation

OpenClaw Docker est un projet open source qui simplifie le déploiement d'OpenClaw avec Docker Compose.

Le projet utilise directement l'image Docker officielle d'OpenClaw, sans avoir besoin de cloner son repository source ni de construire une image personnalisée.

Il est conçu pour fonctionner avec Docker Desktop sous Windows, tout en restant compatible avec les environnements Linux disposant de Docker Compose.

## Fonctionnalités

- Déploiement avec Docker Compose.
- Image officielle OpenClaw.
- Version OpenClaw fixée à 2026.9.3.
- Google Gemini comme AI provider par defaut.
- Modèle par défaut : google/gemini-3.1-flash-lite.
- Deux services : Gateway et CLI.
- Gateway en mode local.
- Docker named volume pour le stockage persistant.
- Backup automatique vers un dossier Windows.
- Restore interactif avec sélection du backup.
- Récupération après suppression des containers et du volume.
- Aucun Chromium requis.
- Configuration des secrets via .env.

## Architecture

```text
Windows / Docker Desktop
          |
          v
     Docker Compose
          |
     +----+----------------+
     |                     |
     v                     v
openclaw-gateway       openclaw-cli
     |                     |
     +----------+----------+
                |
         openclaw-state
          Docker volume
                |
                v
        OpenClaw State
                |
         Backup / Restore
                |
                v
      Windows config-backup
                |
                v
       Google Gemini API
       Gemini 3.1 Flash Lite
```

## Prérequis

- Windows 10/11 ou Linux.
- Docker Desktop ou Docker Engine.
- Docker Compose v2.
- Git Bash ou PowerShell sous Windows.
- Une clé API Google AI Studio.

## Installation

1. Cloner le repository

```bash
git clone https://github.com/TON_USERNAME/openclaw-gemini-docker.git
cd openclaw-gemini-docker
```

2. Préparer les environment variables

- Copier .env.example dans .env

```bash
cp .env.example .env
```

- Modifier .env :

```dotenv
OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:2026.9.3
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_TOKEN=YOUR_SECURE_TOKEN
GEMINI_API_KEY=YOUR_GEMINI_API_KEY
TZ=Africa/Kinshasa
```

- Générer un Gateway token :

```bash
openssl rand -hex 32
```

- Obtenir une clé Gemini :

```http
https://aistudio.google.com/apikey
```

3. Installer OpenClaw

Sous Git Bash :

```bash
./scripts/install.sh
```

Sous PowerShell :

```powershell
.\scripts\install.ps1
```

Le script crée le Docker named volume, initialise la configuration et démarre le Gateway.

4. Accéder au Dashboard

```http
http://127.0.0.1:18789
```

## Configuration

| Paramètre     | Valeur                       |
| ------------- | ---------------------------- |
| OpenClaw      | 2026.9.3                     |
| Gateway mode  | local                        |
| Gateway port  | 18789                        |
| AI provider   | Google                       |
| Default model | google/gemini-3.1-flash-lite |
| Storage       | Docker named volume          |
| Chromium      | Disabled                     |

## Gestion des containers

- Démarrer :

```bash
docker compose up -d
```

- Arrêter :

```bash
docker compose stop
```

- Redémarrer :

```bash
docker compose restart openclaw-gateway
```

- Afficher les logs :

```bash
docker compose logs -f openclaw-gateway
```

- Vérifier le statut :

```bash
docker compose ps
```

### CLI

- Lister les modèles :

```bash
docker compose run --rm openclaw-cli models list
```

- Afficher le statut :

```bash
docker compose run --rm openclaw-cli status
```

- Lancer les diagnostics :

```bash
docker compose run --rm openclaw-cli doctor
```

## Backup et Restore

Les données actives sont stockées dans le Docker named volume :

openclaw-state

Les archives sont enregistrées localement dans :

D:\openclaw-2026.9.3-docker\config-backup

- Créer un backup

```bash
bash scripts/backup.sh
```

Le script arrête temporairement le Gateway, crée une archive complète, sauvegarde le fichier .env et redémarre le Gateway s'il était actif.

- Restaurer un backup

```bash
bash scripts/restore.sh
```

Deux possibilités sont proposées :

1. Sélectionner manuellement une archive.
2. Restaurer automatiquement la dernière archive disponible.

- Récupération après suppression du volume

Le volume peut être recréé à partir d'une archive même après sa suppression :

```bash
docker volume rm openclaw-state
bash scripts/restore.sh
```

**Important** : les archives doivent être conservées en dehors du Docker volume et ne doivent jamais être supprimées avec les containers.

## Sécurité

- Ne jamais publier le fichier .env.
- Ne jamais partager les API keys.
- Ne pas exposer le Gateway directement sur Internet.
- Conserver les backups dans un emplacement privé.
- Utiliser un Gateway token aléatoire et suffisamment long.
- Protéger les archives contenant les sessions et credentials.
- Effectuer régulièrement des tests de restauration.

## Versioning

| Composant     | Version        |
| ------------- | -------------- |
| Repository    | 1.0.0          |
| OpenClaw      | 2026.9.3       |
| Google Gemini | 3.1 Flash Lite |

Le tag Docker fixe la version demandée. Le commit upstream est une référence documentaire et doit être vérifié indépendamment si une garantie exacte de provenance est nécessaire.

## Licence

Ce repository est distribué sous licence MIT.

OpenClaw reste un projet indépendant soumis à sa propre licence. Ce repository n'est ni développé ni officiellement maintenu par OpenClaw ou Google.

Voir LICENSE.

## Contributions

Les contributions sont les bienvenues.

Consulter CONTRIBUTING.md avant de proposer une Pull Request.

## Remerciements
- OpenClaw
- Google Gemini
- Docker

**OpenClaw Docker — Un déploiement simple, persistant et reproductible.**

<!--
MSYS_NO_PATHCONV=1 docker run --rm -i \
  -v openclaw-state:/data \
  alpine:3.20 sh -c 'cat > /data/openclaw.json' <<'EOF'
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
EOF -->
