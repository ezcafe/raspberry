# Rocket.Chat

## Updating Rocket.Chat Docker Image

Your data should not be affected by this, since it's located in the mongo image.
```
docker pull registry.rocket.chat/rocketchat/rocket.chat:latest
docker-compose stop rocketchat
docker-compose rm rocketchat
docker-compose up -d rocketchat
```