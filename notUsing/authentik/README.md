# authentik

## Create account

Goto: https://<your-url>/if/flow/initial-setup/

## Backup and Restore

### Create backup folder

mkdir authentik

### Make .sh script as executable

chmod +x ../scripts/backup-post-script.sh


### Manual Backup

<!-- https://github.com/tiredofit/docker-db-backup -->

```
docker exec -it authentik-db-backup bash
backup-now
```

### Restore

```
docker exec -it authentik-db-backup bash
restore
```