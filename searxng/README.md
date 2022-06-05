# searxng

## Config

docker volume ls
=> docker volume name: searxng_searxng_data

docker volume inspect searxng_searxng_data
=> Mountpoint: /var/lib/docker/volumes/searxng_searxng_data/_data

sudo nano /var/lib/docker/volumes/searxng_searxng_data/_data/settings.yml
=> update engines