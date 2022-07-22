# Ergo

### Get oper password
Run `docker-compose logs` to get the oper password

### Update ircd.yaml file

Update file `ergo/ircd.yaml`. Update following fields:
- network.name
- server.name

### Overwrite config file

docker volume ls 
=> docker volume name: ergo_ergo_volume
docker volume inspect ergo_ergo_volume
=> Mountpoint: /var/lib/docker/volumes/ergo_ergo_volume/_data

sudo nano /var/lib/docker/volumes/ergo_ergo_volume/_data/ircd.yaml
