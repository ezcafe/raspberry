# duplicati

Go to http://192.168.1.4:19988/ to backup data

For more information
https://www.danielmartingonzalez.com/en/backups-towards-docker/

## Setup
Update docker-compose.yml volume 

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

