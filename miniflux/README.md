# Miniflux RSS

## Start the database

```
docker-compose up -d db
```

Check health of database by running `docker ps`. Wait until its status becomes healthy

### check by cli
```
docker exec -it miniflux-db psql -U yourDbUser
```

## Start Miniflux

```
docker-compose up -d app
```

## Backup and Restore

### Manual Backup
<!-- https://github.com/tiredofit/docker-db-backup -->
```
docker exec -it miniflux-backup bash
backup-now
```

### Restore
```
docker exec -it miniflux-backup bash
restore
```