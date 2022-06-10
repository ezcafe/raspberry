# Pihole

Run Pihole and Pihole Unbound by

```
cd ~/pihole-unbound
docker-compose up -d
```

To update Pihole

```
docker-compose down
docker pull pihole/pihole
docker pull cbcrowe/pihole-unbound
docker-compose up -d
```