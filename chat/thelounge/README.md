# thelounge

## Add user
docker exec --user node -it [container_name] thelounge add [username]

## Installing additional themes
https://thelounge.chat/docs/usage#installing-additional-themes

## Installing plugins
https://thelounge.chat/docs/usage#installing-plugins

## Update config
https://thelounge.chat/docs/configuration

### Get thelounge volume name
docker volume ls  
=> thelounge_thelounge_data

### Get volume location
docker volume inspect [volume_name] 
=> "Mountpoint": "/var/lib/docker/volumes/thelounge_thelounge_data/_data",

### Edit config.js file
sudo nano [path_to_volume_location]/config.js