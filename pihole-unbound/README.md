# Pihole

## Update Pihole

```
docker-compose down
docker pull pihole/pihole
docker pull cbcrowe/pihole-unbound
docker-compose up -d
```

## Change password

```
docker exec -it pihole /bin/bash
pihole -a -p somepasswordhere
```