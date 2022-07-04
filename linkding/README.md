# linkding

## Create user
```
docker-compose exec linkding python manage.py createsuperuser --username=yourUser --email=yourEmail@test.com
```

## Backup and Restore

### Manual Backup
<!-- https://github.com/offen/docker-volume-backup -->
```
docker exec linkding-backup backup
```

### Restore
1. Stop the container(s) that are using the volume

2. Restore
```
cd ~/raspberry/linkding
docker run --rm -it -v linkding_backup_volume:/backup/my-app-backup -v /home/ezcafe/backups/linkding:/archive:ro alpine tar -xvzf /archive/<full-backup-filename>.tar.gz
```

4. Restart the container(s) that are using the volume