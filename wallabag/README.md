# WallaBag

Wait a few mins for WallaBag to set it up

## Backup and Restore

### Make .sh script as executable
chmod +x backup-post-script.sh

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