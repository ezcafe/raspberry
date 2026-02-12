# Pocket ID

## Setup

Go to https://auth.example.com/setup to add passkey

### Make backup folder accessible

mkdir -p ~/syncthing/backups/pocket-id
chown -R 1000:1000 ~/syncthing/backups/pocket-id

## Backup and Restore

### Make backup folder accessible

mkdir -p ~/backups/pocket-id
chown 1000:1000 ~/backups/pocket-id

### Make .sh script as executable

chmod +x ../scripts/backup-pre-script.sh
chmod +x ../scripts/backup-post-script.sh

chmod u=rwx ../scripts/backup-pre-script.sh
chmod u=rwx ../scripts/backup-post-script.sh

### Manual Backup

<!-- https://github.com/tiredofit/docker-db-backup -->

```
docker exec -it pocket-id-db-backup bash
backup-now
```

### Restore

```
docker exec -it pocket-id-db-backup bash
restore
```
