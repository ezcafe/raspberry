# Syncthing

## Fix permission

mkdir ~/syncthing
mkdir ~/syncthing/backups
sudo chown -R 1000:1000 ~/syncthing/backups
sudo chmod -R 750 ~/syncthing/backups

## Share folder

The share path related to root path
For example: ~/backups