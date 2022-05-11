# duplicati

Go to http://192.168.1.4:19988/ to backup data

For more information
https://easycode.page/duplicati-on-docker-local-drive-backup/
https://github.com/danimart1991/docker-compose-files/tree/master/duplicati

## Backup
### General backup settings
- Name: raspberry backup
- Passphrase: <your passphrase>
- Repeat Passphrase: <your passphrase>

### Backup destination
- Storage Type: mega.nz
- Folder path: raspberry
- Username: <mega.nz username>
- Password: <mega.nz password>

### Source data
Select docker_config and docker_source folders

### Schedule
Select the time you want to backup

### General options
Select Backup retention type that you want