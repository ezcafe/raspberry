# Actual server

## Pocket ID

### Create Provider

Go to your auth provider
Create OIDC Client with these information

- name: actual-budget
- Callback URLs: https://money.example.com/openid/callback

### Update actual config

Setup following this guide https://actualbudget.org/docs/experimental/oauth-auth/

Update .env file

ACTUAL_OPENID_DISCOVERY_URL=https://auth.example.com/.well-known/openid-configuration
ACTUAL_OPENID_CLIENT_ID=copy from OIDC provider
ACTUAL_OPENID_CLIENT_SECRET=copy from OIDC provider
ACTUAL_OPENID_SERVER_HOSTNAME=https://money.example.com