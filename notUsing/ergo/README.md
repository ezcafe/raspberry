# Ergo

NOTE: irc server doesn't work with Cloudflare

### Get oper password
Run `docker-compose logs` to get the oper password

### Open config file

docker volume ls 
=> docker volume name: ergo_ergo_volume
docker volume inspect ergo_ergo_volume
=> Mountpoint: /var/lib/docker/volumes/ergo_ergo_volume/_data

sudo nano /var/lib/docker/volumes/ergo_ergo_volume/_data/ircd.yaml


### Update config file

Update following fields:
- network.name
- server.name
- proxy-allowed-from