# Wordpress

Wordpress depends on nginx-proxy.
We will need to run nginx-proxy first.

NOTE: 
- After you launch your wordpress docker image. You can go to your internal ip and make sure it works, but STOP at the WordPress install screen.
- Setup nginx proxy first.
- Then you should be able to access your site through the domain name and complete the setup process.
- Always run the initial setup for your wordpress instance using the public domain and not the internal domain/IP.
- Fill in the fields on the install screen and click continue. You’ll see a screen saying that everything is good to go and advising you to login with the account you just created.
- Once you login, you will want to run any updates that may need to be run and then install a couple of plugins.
- The most important plugin to install is called “SSL Insecure Content Fixer“. This will help prevent any SSL redirect issues.

## Fix Error establishing a database connection

Change `MYSQL_DATABASE` in .env file, then run
```
docker-compose up -d --force-recreate
```

Restart your wordpress server

## Config Cloudflare

Goto SSL/TLS, select Full

## Install the Cloudflare plugin in Wordpress

Login to Cloudflare plugin with your Cloudflare account and token.
Then click on Optimize Cloudflare settings