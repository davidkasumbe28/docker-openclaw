
# Guide d'installation

## Windows

1. Installer Docker Desktop.
2. Installer Git for Windows si Git Bash est utilisé.
3. Cloner le repository.
4. Copier `.env.example` vers `.env`.
5. Configurer `GEMINI_API_KEY`.
6. Configurer `OPENCLAW_GATEWAY_TOKEN`.
7. Exécuter `scripts/install.ps1` ou `scripts/install.sh`.

## Linux

Prérequis :
- Docker Engine
- Docker Compose v2
- Bash

Exécuter :

```bash
cp .env.example .env
chmod +x scripts/*.sh
bash scripts/install.sh
```

## Dashboard

http://127.0.0.1:18789

## Vérification

```bash
bash scripts/verify.sh
```
