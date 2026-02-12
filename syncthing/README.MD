# Syncthing

## Fix permission

mkdir ~/backups
mkdir ~/backups/database
sudo chown -R 1000:1000 ~/backups/database

## Share folder

The share path related to root path
For example:
- root path: ~/backups
- share path: ~/database