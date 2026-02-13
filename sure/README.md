# sure

## Backup and Restore

### Make backup folder accessible

mkdir -p ~/backups/database/sure
chown -R 1000:1000 ~/backups/database/sure

### Make .sh script as executable

chmod u=rwx ../scripts/backup-pre-script.sh
chmod u=rwx ../scripts/backup-post-script.sh

### Manual Backup

<!-- https://github.com/tiredofit/docker-db-backup -->

```
docker exec -it sure-db-backup bash
backup-now
```

### Restore

```
docker exec -it sure-db-backup bash
restore
```