# jotty

## Pocket ID

### Create Provider

Go to your auth provider
Create OIDC Client with these information

- name: jotty
- Callback URLs: https://note.example.com/api/oidc/callback

### Update .env file

Update .env file

OIDC_ISSUER=https://auth.example.com
OIDC_CLIENT_ID=copy from OIDC provider
OIDC_CLIENT_SECRET=copy from OIDC provider

## Backup and Restore

### Make backup folder accessible

mkdir -p ~/backups/jotty && cd ~/backups/jotty
mkdir -p config data/users data/checklists data/notes data/sharing data/encryption cache && sudo chown -R 1000:1000 data/ && sudo chown -R 1000:1000 config/ && sudo chown -R 1000:1000 cache/
