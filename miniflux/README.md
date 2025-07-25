# Miniflux RSS

## Pocket ID

### Create Provider

Go to your auth provider
Create OIDC Client with these information

- name: miniflux
- Callback URLs: https://news.example.com/oauth2/oidc/callback

### Update .env file

Update .env file

OAUTH2_PROVIDER=oidc
OAUTH2_CLIENT_ID=copy from OIDC provider
OAUTH2_CLIENT_SECRET=copy from OIDC provider
OAUTH2_REDIRECT_URL=https://news.example.com/oauth2/oidc/callback
OAUTH2_OIDC_DISCOVERY_ENDPOINT=https://auth.example.com # without trailing /
OAUTH2_USER_CREATION=1

## Authentik

### Create Provider

- Select `OAuth2/OpenID Provider`
- Name: `Miniflux`
- Authentication flow: default-authentication-flow (Welcome to authentik!)
- Authorization flow: default-provider-authorization-implicit-consent (Authorize Application)
- Client type: Confidential
- Client ID: <auto-generated>
- Client Secret: <auto-generated>
- Redirect URIs/Origins (RegEx): https://<your-rss-domain>/oauth2/oidc/callback
- Signing Key: `authentik Self-signed Certificate`

### Create Application

- Name: `Miniflux`
- Slug: `miniflux`
- Group: `selfhosted`
- Provider: <select-created-miniflux-provider>
- Policy engine mode: any

### Update .env file

Update these values with the values you created before

OAUTH2_PROVIDER=oidc
OAUTH2_CLIENT_ID=replace_me
OAUTH2_CLIENT_SECRET=replace_me
OAUTH2_REDIRECT_URL=https://<your-rss-domain>/oauth2/oidc/callback
OAUTH2_OIDC_DISCOVERY_ENDPOINT=https://<your-auth-domain>/application/o/miniflux/
OAUTH2_USER_CREATION=1

## Start the database

```
docker-compose up -d db
```

Check health of database by running `docker ps`. Wait until its status becomes healthy

### check by cli

```
docker exec -it miniflux-db psql -U yourDbUser
```

## Start Miniflux

```
docker-compose up -d app
```

## Backup and Restore

### Make backup folder accessible

mkdir -p /home/ezcafe/backups/miniflux
chown -R 1000:1000 /home/ezcafe/backups/miniflux
chmod -R 777 /home/ezcafe/backups/miniflux

### Make .sh script as executable

chmod u=rwx ../scripts/backup-pre-script.sh
chmod u=rwx ../scripts/backup-post-script.sh

### Manual Backup

<!-- https://github.com/tiredofit/docker-db-backup -->

```
docker exec -it miniflux-db-backup bash
backup-now
```

### Restore

```
docker exec -it miniflux-db-backup bash
restore
```

## Add Miniflux to NetNewsWire

- Go to your miniflux instance (let's say http://192.168.1.1:1234/
- Open Settings, observe new Google Reader section
- Check Activate Google Reader API, create Username and Password and click Update
- Open NetNewsWire > Preferences... > Accounts > + > select FreshRSS under Self-hosted > Continue
- Set Login: to Username, Password: to Password you've used when activating Google Reader API in Miniflux
- Use your instance URL (e.g. http://192.168.1.1:1234/) as API URL:, click Create
- You'll find yourself back in the Accounts dialog, feel free to add Name so that it shows nicely in the sidebar
