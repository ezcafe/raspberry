# Mattermost

## Create the required directories

```
mkdir -p ./volumes/app/mattermost/{config,data,logs,plugins,client/plugins,bleve-indexes} && sudo chown -R 2000:2000 ./volumes/app/mattermost
```

## Deploy
sudo docker-compose -f docker-compose.yml -f docker-compose.without-nginx.yml up -d