# Joplin

## Backup and Restore

### Make .sh script as executable

chmod +x ../scripts/backup-post-script.sh

### Manual Backup

<!-- https://github.com/tiredofit/docker-db-backup -->

```
docker exec -it joplin-server-db-backup bash
backup-now
```

### Restore

```
docker exec -it joplin-server-db-backup bash
restore
```
