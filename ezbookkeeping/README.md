# ezbookkeeping

## Backup and Restore

### Make backup folder accessible

mkdir -p /home/ezcafe/backups/ezbookkeeping
chown 1000:1000 /home/ezcafe/backups/ezbookkeeping

### Make .sh script as executable

chmod +x ../scripts/backup-post-script.sh

### Manual Backup

<!-- https://github.com/tiredofit/docker-db-backup -->

```
docker exec -it ezbookkeeping-db-backup bash
backup-now
```

### Restore

```
docker exec -it ezbookkeeping-db-backup bash
restore
```
