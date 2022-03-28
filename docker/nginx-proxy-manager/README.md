# Nginx Proxy Manager

Webiste: https://nginxproxymanager.com/guide/#quick-setup
Support forum: https://www.reddit.com/r/nginxproxymanager/
Tutorial: https://apexlemons.com/2021/09/01/ultimate-home-lab-dynamic-ips-cloudflare-nginx-proxy-manager/

## Setup Cloudflare

Login to Cloudflare, then add DNS Record for your domain, for example

Type: CNAME
Name: subdomain
Content: @
Proxy Status: DNS only
TTL: Auto

`CNAME` with Content `@` will point `subdomain.example.com` to `example.com`
`DNS only` is required to create SSL later. We will change it back to `Proxied` after SSL is created.

## First load

Log in to the Admin UI
http://<your-ip>:81

Default Admin User:
Email:    admin@example.com
Password: changeme

## Create Wildcard SSL Certificates

Go to SSL Certificates > Add SSL Certificate

For example: We want to create subdomains for example.com
- Domain Names: *.example.com
- Check: Use a DNS Challenge
- DNS Provider: Cloudflare
- Credentials File Content: dns_cloudflare_api_token = <your-API-Token>
Create a new [Cloudflare API Token](https://dash.cloudflare.com/profile/api-tokens) and put it in <your-API-Token>
- Check: I Agree to ...

## Create proxy host for your websites

Go to Hosts > Proxy Hosts > Add Proxy Host

### Tab Details
- Domain Name: subdomain.example.com
- Scheme: http
- Forward Hostname / IP: <your-raspberry-ip>
- Forward Port: <your-app-port>
- Check: Cache Assets
- Check: Block Common Exploits

### Tab SSL
SSL Certificate: select *.example.com
Check: Force SSL
Check: HTTP/2 Support

Then Save

### Update Cloudflare

Update `subdomain` to `Proxied`


### Read more

- https://husarnet.com/blog/reverse-proxy-gui
- https://kinsta.com/blog/reverse-proxy/