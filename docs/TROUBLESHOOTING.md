
# Troubleshooting

## Missing config

Vérifier :

```bash
docker volume inspect openclaw-state
```

Puis vérifier le fichier :

```bash
MSYS_NO_PATHCONV=1 docker run --rm \
  -v openclaw-state:/data \
  alpine:3.20 cat /data/openclaw.json
```

## ENOENT / fstat

Éviter les bind mounts Windows pour le stockage actif.

Utiliser le Docker named volume `openclaw-state`.

## Git Bash path conversion

Pour les commandes Docker utilisant des chemins Linux :

```bash
MSYS_NO_PATHCONV=1
```

Pour les bind mounts Windows, utiliser :

```bash
cygpath -am
```

## Gemini authentication

Vérifier :

- `GEMINI_API_KEY`
- La validité de la clé Google AI Studio.
- La disponibilité du modèle configuré.

## Logs

```bash
docker compose logs --tail=100 openclaw-gateway
```

## Compose validation

```bash
docker compose config --quiet
```
