# Wordpress

Wordpress depends on nginx-proxy.
We will need to run nginx-proxy first.

## Fix Error establishing a database connection

Change `MYSQL_DATABASE` in .env file, then run
```
docker-compose up -d --force-recreate
```