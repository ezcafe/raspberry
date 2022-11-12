# WallaBag

Wait a few mins for WallaBag to set it up

## Backup and Restore

### Create backup folder

mkdir wallabag

### Make .sh script as executable

chmod +x ../scripts/backup-post-script.sh

### Manual Backup

<!-- https://github.com/tiredofit/docker-db-backup -->

```
docker exec -it wallabag-db-backup bash
backup-now
```

### Restore

```
docker exec -it wallabag-db-backup bash
restore
```
