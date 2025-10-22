# rwMarkable

## Backup and Restore

### Make backup folder accessible

mkdir -p /home/ezcafe/backups/rwmarkable
mkdir -p /home/ezcafe/backups/rwmarkable/users /home/ezcafe/backups/rwmarkable/checklists /home/ezcafe/backups/rwmarkable/notes /home/ezcafe/backups/rwmarkable/sharing
sudo chown -R 1000:1000 /home/ezcafe/backups/rwmarkable

mkdir -p /home/ezcafe/backups/rwmarkable/config
chown -R 1000:1000 /home/ezcafe/backups/rwmarkable/config
chmod -R 755 /home/ezcafe/backups/rwmarkable/config