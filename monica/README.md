# Monica

Run this command to get connect info

```
mysqlCid="$(docker run -d \
 -e MYSQL_RANDOM_ROOT_PASSWORD=true \
 -e MYSQL_DATABASE=yourDbName \
 -e MYSQL_USER=yourDbUser \
 -e MYSQL_PASSWORD=yourDbPassword \
 "mariadb:latest")"
```