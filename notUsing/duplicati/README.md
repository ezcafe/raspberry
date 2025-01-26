# duplicati

## Allow port 19988

sudo ufw allow 19988 comment duplicati

## Setup

Go to http://192.168.2.4:19988/ to backup data

For more information
https://www.danielmartingonzalez.com/en/backups-towards-docker/

## Backup

### General backup settings

- Name: raspberry backup
- Passphrase: <your passphrase>
- Repeat Passphrase: <your passphrase>

### Backup destination

- Storage Type: mega.nz
- Folder path: /raspberry/
- Username: <mega.nz username>
- Password: <mega.nz password>
- Advanced options: auth-two-factor-key - input the 2fa key when you setup 2fa for mega.nz

### Source data

Select backup_backups and backup_raspberry folders

### Schedule

Select the time you want to backup

### General options

Select Backup retention type that you want
