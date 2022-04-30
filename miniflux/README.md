# Miniflux RSS

## Start the database

```
docker-compose up -d miniflux_db
```

Check health of database by running `docker ps`. Wait until its status becomes healthy

## Start Miniflux

```
docker-compose up -d miniflux_app
```