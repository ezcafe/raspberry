# Joplin

## Update the admin user credentials

By default, Joplin Server will be setup with an admin user with email admin@localhost and password admin.
For security purposes, the admin user's credentials should be changed.
On the Admin Page, login as the admin user. In the upper right, select the Profile button update the admin password.

## Create a user for sync

While the admin user can be used for synchronisation, it is recommended to create a separate non-admin user for it.
To do so, navigate to the Users page - from there you can create a new user.
Once this is done, you can use the email and password you specified to sync this user account with your Joplin clients.

## Backup and Restore

### Make .sh script as executable

chmod +x ../scripts/backup-post-script.sh

### Manual Backup

<!-- https://github.com/tiredofit/docker-db-backup -->

```
docker exec -it joplin-server-db-backup bash
backup-now
```

### Restore

```
docker exec -it joplin-server-db-backup bash
restore
```
