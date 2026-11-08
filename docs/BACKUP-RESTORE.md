
# Backup et Restore

## Emplacement

Les données actives sont stockées dans le Docker named volume :

`openclaw-state`

Les backups sont stockés dans :

`config-backup/`

## Backup manuel

```bash
bash scripts/backup.sh
```

## Restore interactif

```bash
bash scripts/restore.sh
```

Le Restore propose deux options :

1. Sélectionner une archive précise.
2. Restaurer automatiquement le dernier backup.

## Suppression du volume

Le volume est déclaré `external: true`.

Cette déclaration empêche Docker Compose de le supprimer lors de `docker compose down -v`.

Si le volume est supprimé manuellement, il peut être recréé :

```bash
docker volume create openclaw-state
```

Puis restauré depuis une archive.

## Bonnes pratiques

- Effectuer un backup avant une mise à jour.
- Tester régulièrement le Restore.
- Conserver une copie externe des archives.
- Ne jamais publier les backups.
