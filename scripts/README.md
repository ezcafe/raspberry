# Scripts

## backup-databases.sh

Backs up **Postgres** and **SQLite** databases from docker-compose stacks in named folders. For each folder, the script finds the folder by name, reads `.env`, detects the database from `docker-compose.yml`, and writes a backup under the destination path.

### Usage

```bash
./scripts/backup-databases.sh FOLDER_NAMES DESTINATION_PATH
```

- **FOLDER_NAMES** – Comma-separated folder names (e.g. `miniflux,pocket-id`).
- **DESTINATION_PATH** – Base path for backups (e.g. `~/backups`). Backups are written under `DESTINATION_PATH/<foldername>/<foldername>_<datetime>.sql`. To match paths like `~/backups/database/miniflux/`, use `~/backups/database` as the destination.

### Example

```bash
./scripts/backup-databases.sh miniflux,pocket-id ~/backups
```

From the repo root you can use an alias: `alias backup='./scripts/backup-databases.sh'`, then run: `backup miniflux,pocket-id ~/backups`.

Creates:

- `~/backups/miniflux/miniflux_20260215-143022.sql`
- `~/backups/pocket-id/pocket-id_20260215-143022.sql`

### Behavior

- **Folder lookup**: Folders are searched by name under the repository root (parent of `scripts/`), up to 3 levels deep. The first matching directory is used.
- **Postgres**: Detects services with `image: postgres` in `docker-compose.yml`, uses `container_name` (or resolves via `docker compose ps -q db`), and reads DB name/user from the compose `environment` section or `.env`.
- **Supported env variables** (compose or .env): `DB_NAME`, `DB_USER`, `POSTGRES_DB`, `POSTGRES_USER`, `DB_USERNAME`, `DB_DATABASE`, `DB_DATABASE_NAME`.
- **SQLite**: Detects services with `DB01_TYPE=sqlite3` and `DB01_HOST` (path inside container) and runs `sqlite3 ... .dump` via `docker exec`.
- If a folder has no database (or the DB container is not running), a warning is printed and the script continues with the next folder.
- If a folder's compose uses env variable names not in the supported list, a warning lists the supported patterns so you can add the appropriate vars to `.env` or adjust the compose.

### Requirements

- **bash**, **docker**
- `.env` in each folder (for Postgres credentials when not in compose)
- Containers must be running for `docker exec` backup

### Cron: daily backup

To run the backup every day (e.g. at 2:00 AM):

1. **Choose** which folder names to backup (comma-separated) and the destination path, e.g. `sure,miniflux,pocket-id` and `~/backups/database`.
2. **Open crontab:**  
   `crontab -e`
3. **Add a line** (replace `USER`, path to repo, folder list, and destination with your values):

   ```cron
   # Daily DB backup at 2:00 AM
   0 2 * * * cd /home/USER/raspberry && ./scripts/backup-databases.sh "sure,miniflux,pocket-id" /home/USER/backups/database >> /home/USER/backups/backup-databases.log 2>&1
   ```

   - The job must run from the **repository root** (`cd .../raspberry`) so the script can find the folders.
   - Use **absolute paths** in cron (no `~`); replace `USER` with your Linux username.
   - Optional: change `0 2` to another time (e.g. `30 23` for 11:30 PM).

4. **Optional – log rotation:** if you log to a file, rotate it occasionally, e.g. with logrotate or a weekly cron that truncates/archives the log.

---

## restore-databases.sh

Restores **Postgres** and **SQLite** databases from backup files produced by `backup-databases.sh`. For each folder/backup pair, the script finds the folder by name, reads `.env` and `docker-compose.yml`, detects the database type, and restores the given backup file into that database.

### Usage

```bash
./scripts/restore-databases.sh FOLDER_NAMES BACKUP_FILES
```

- **FOLDER_NAMES** – Comma-separated folder names (e.g. `sure,miniflux`). Same order as backup files.
- **BACKUP_FILES** – Comma-separated paths to `.sql` backup files (e.g. `/home/ezcafe/backups/sure/sure_20260218.sql,/home/ezcafe/backups/miniflux/miniflux_20260218.sql`).

### Example

```bash
./scripts/restore-databases.sh "sure,miniflux" "/home/ezcafe/backups/sure/sure_20260218-064234.sql,/home/ezcafe/backups/miniflux/miniflux_20260218.sql"
```

### Behavior

- **Pairing**: The first folder name is restored from the first backup file, the second from the second, etc. The number of comma-separated entries must match.
- **Postgres**: Restores by piping the backup SQL into `psql -U user -d dbname` inside the Postgres container. Uses the same env variable patterns as the backup script (see above). If the database already has data, you may need to drop/recreate it first (e.g. stop the app, drop DB, then restore).
- **SQLite**: Removes the existing DB file in the container, then feeds the backup SQL into `sqlite3` for a clean replace.
- Containers must be running. Backup files must exist and be plain SQL (as produced by `backup-databases.sh`).

### Requirements

- **bash**, **docker**
- `.env` in each folder (for Postgres credentials)
- Containers must be running

---

### Other scripts

- **backup-pre-script.sh** / **backup-post-script.sh** – Used by [tiredofit/docker-db-backup](https://github.com/tiredofit/docker-db-backup) in some stacks (e.g. miniflux, pocket-id) for pre/post backup hooks.
