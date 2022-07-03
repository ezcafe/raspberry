# linkding

## Create user
```
docker-compose exec linkding python manage.py createsuperuser --username=yourUser --email=yourEmail@test.com
```

## Backup and Restore

### Manual Backup
<!-- https://github.com/tiredofit/docker-db-backup -->
```
docker exec -it linkding-backup bash
backup-now
```

### Restore
```
docker exec -it linkding-backup bash
restore
```