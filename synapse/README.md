# Matrix

## Generating a configuration file

```
docker-compose run --rm synapse generate
```

## Generating an (admin) user
docker exec -it matrix register_new_matrix_user -u myuser -p mypw -a -c /data/homeserver.yaml