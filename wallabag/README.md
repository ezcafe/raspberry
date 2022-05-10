# Wallabag

Run migration command

```
$ docker exec -t NAME_OR_ID_OF_YOUR_WALLABAG_CONTAINER /var/www/wallabag/bin/console doctrine:migrations:migrate --env=prod --no-interaction
```