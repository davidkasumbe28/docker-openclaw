
# Guide de contribution

Les contributions sont les bienvenues.

## Workflow

1. Forker le repository.
2. Créer une feature branch.
3. Effectuer les modifications.
4. Tester les changements.
5. Mettre à jour la documentation.
6. Ouvrir une Pull Request.

## Convention de nommage

- `feature/description`
- `fix/description`
- `docs/description`
- `security/description`

## Validation

```bash
docker compose config --quiet
bash scripts/verify.sh
```

## Pull Request

Chaque Pull Request doit préciser :

- Le problème traité.
- La solution proposée.
- Les tests réalisés.
- Les éventuelles modifications de configuration.

Ne jamais inclure de secrets, API keys, fichiers `.env` ou backups.
