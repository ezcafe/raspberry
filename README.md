# Raspberry

## Tiny Tiny RSS

### Installation
```
git clone https://git.tt-rss.org/fox/ttrss-docker-compose.git
git checkout static-dockerhub
```

### Edit configuration files

```
cp -a .env-dist .env
nano .env
```

### Pull and start the container

```
docker-compose pull && docker-compose up -d
```

### Login
Default login credentials
- Username: admin
- Password: password