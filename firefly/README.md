# Firefly

Wait a few mins for WallaBag to set it up

## Backup and Restore

### Create backup folder

mkdir firefly

### Make .sh script as executable

chmod +x ../scripts/backup-post-script.sh

### Manual Backup

<!-- https://github.com/tiredofit/docker-db-backup -->

```
docker exec -it firefly-db-backup bash
backup-now
```

### Restore

```
docker exec -it firefly-db-backup bash
restore
```
