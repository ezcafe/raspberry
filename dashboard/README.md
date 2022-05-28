# Dashboard

## Run Dashboard

```
cd dashboard
docker-compose up -d
```

## Copy data files

### Get container id

```
docker container ls
```

### Update json files in data folder

...

### Copy json files to data folder

```
docker cp data/apps.json [CONTAINER_ID]:/app/data
docker cp data/bookmarks.json [CONTAINER_ID]:/app/data
docker cp data/greeter.json [CONTAINER_ID]:/app/data
docker cp data/search.json [CONTAINER_ID]:/app/data
docker cp data/themes.json [CONTAINER_ID]:/app/data
```