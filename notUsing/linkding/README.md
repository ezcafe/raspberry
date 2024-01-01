# linkding

## Create user

```
docker-compose exec linkding python manage.py createsuperuser --username=yourUser --email=yourEmail@test.com
```

## Backup and Restore

### Create backup folder

mkdir linkding

### Make .sh script as executable

chmod +x ../scripts/backup-post-script.sh

### Manual Backup

<!-- https://github.com/tiredofit/docker-db-backup -->

```
docker exec -it linkding-db-backup bash
backup-now
```

### Restore

```
docker exec -it linkding-db-backup bash
restore
```
