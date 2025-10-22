# jotty

## Pocket ID

### Create Provider

Go to your auth provider
Create OIDC Client with these information

- name: jotty
- Callback URLs: https://note.example.com/oauth2/oidc/callback

### Update .env file

Update .env file

OIDC_ISSUER=https://auth.example.com
OIDC_CLIENT_ID=copy from OIDC provider
OIDC_CLIENT_SECRET=copy from OIDC provider

## Backup and Restore

### Make backup folder accessible


mkdir -p /home/ezcafe/backups/jotty/cache
mkdir -p /home/ezcafe/backups/jotty/config
mkdir -p /home/ezcafe/backups/jotty/data
chown -R 1000:1000 /home/ezcafe/backups/jotty/
chmod -R 755 /home/ezcafe/backups/jotty/