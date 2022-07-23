# Thelounge chat

## Add user
docker exec --user node -it thelounge thelounge add [username]

### Open config file

docker volume ls 
=> docker volume name: thelounge_thelounge_volume
docker volume inspect thelounge_thelounge_volume
=> Mountpoint: /var/lib/docker/volumes/thelounge_thelounge_volume/_data

sudo nano /var/lib/docker/volumes/thelounge_thelounge_volume/_data/config.js

### Update config file

Update following fields:
- defaults.name
- defaults.host
- defaults.port