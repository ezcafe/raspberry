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
docker exec <pihole_container_name> pihole -a -p supersecurepassword
```