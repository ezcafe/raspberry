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
