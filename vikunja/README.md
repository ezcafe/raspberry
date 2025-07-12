# vikunja

## Pocket ID

### Create Provider

Go to your auth provider
Create OIDC Client with these information

- name: task.example.com
- Callback URLs: https://task.example.com/auth/openid/pocketid

### Update config

Update config file

auth.local.enabled = false
auth.openid.enabled = true
auth.openid.redirecturl=https://task.example.com/auth/openid/pocketid
auth.openid.providers.name=Passkey
auth.openid.providers.authurl=https://auth.example.com
auth.openid.providers.logouturl=copy from OIDC provider
auth.openid.providers.clientid=copy from OIDC provider
auth.openid.providers.clientsecret=copy from OIDC provider

Go to https://unsplash.com/oauth/applications to create an application
backgrounds.providers.unsplash.accesstoken=copy from application
backgrounds.providers.unsplash.applicationid=copy from application

## Backup and Restore

### Make backup folder accessible

mkdir -p /home/ezcafe/backups/vikunja
chown 1000:1000 /home/ezcafe/backups/vikunja

### Make .sh script as executable

chmod u=rwx ../scripts/backup-pre-script.sh
chmod u=rwx ../scripts/backup-post-script.sh

### Manual Backup

<!-- https://github.com/tiredofit/docker-db-backup -->

```
docker exec -it vikunja-db-backup bash
backup-now
```

### Restore

```
docker exec -it vikunja-db-backup bash
restore
```