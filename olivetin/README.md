# olivetin

## Install docker compose

/usr/bin/docker exec -u 0 -i olivetin /bin/bash -c "/bin/mkdir -p /usr/local/lib/docker/cli-plugins && /bin/curl -SL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose && /bin/chmod +x /usr/local/lib/docker/cli-plugins/docker-compose"