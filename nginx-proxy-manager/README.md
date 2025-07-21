# Nginx Proxy Manager

Webiste: https://nginxproxymanager.com/guide/#quick-setup
Support forum: https://www.reddit.com/r/nginxproxymanager/
Tutorial: https://apexlemons.com/2021/09/01/ultimate-home-lab-dynamic-ips-cloudflare-nginx-proxy-manager/

## Setup Port Forwarding

## Setup Cloudflare

Login to Cloudflare, then add DNS Record for your domain, for example

Type: CNAME
Name: subdomain
Content: @
Proxy Status: DNS only
TTL: Auto

`CNAME` with Content `@` will point `subdomain.example.com` to `example.com`
`DNS only` is required to create SSL later.
We will change it back to `Proxied` after SSL is created.

## First load

Log in to the Admin UI
http://<your-ip>:19998

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
- Check: Block Common Exploits

### SKIP THIS: Tab Custom locations
Click Add location.
If forwarding to a WordPress server, type “/wp-admin” as the location.
The scheme should match the previous page, which is http in this case.
Again, add your server IP and forward port like the previous page as well.

### Tab SSL
SSL Certificate: select *.example.com
Check: Force SSL
Check: HTTP/2 Support

Then Save

## Enable the port in firewall

sudo ufw allow <your-app-port>

## Update Cloudflare

Update `subdomain` to `Proxied`

## Wordpress only: Setup Wordpress

Go to the newly created subdomain.example.com to setup your Wordpress

## Forgot password?

https://github.com/NginxProxyManager/nginx-proxy-manager/issues/230#issuecomment-815078355

## Read more

- https://husarnet.com/blog/reverse-proxy-gui
- https://kinsta.com/blog/reverse-proxy/