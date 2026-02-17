# Scripts

## backup-databases.sh

Backs up **Postgres** and **SQLite** databases from docker-compose stacks in named folders. For each folder, the script finds the folder by name, reads `.env`, detects the database from `docker-compose.yml`, and writes a backup under the destination path.

### Usage

```bash
./scripts/backup-databases.sh FOLDER_NAMES DESTINATION_PATH
```

- **FOLDER_NAMES** – Comma-separated folder names (e.g. `miniflux,pocket-id`).
- **DESTINATION_PATH** – Base path for backups (e.g. `~/backups`). Backups are written under `DESTINATION_PATH/<foldername>/<foldername>_<datetime>.sql`.

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
- **Postgres**: Detects services with `image: postgres` in `docker-compose.yml`, uses `container_name` (or resolves via `docker compose ps -q db`), and reads `POSTGRES_DB`/`POSTGRES_USER` (or `DB_NAME`/`DB_USER`) from the compose `environment` section or from `.env`.
- **SQLite**: Detects services with `DB01_TYPE=sqlite3` and `DB01_HOST` (path inside container) and runs `sqlite3 ... .dump` via `docker exec`.
- If a folder has no database (or the DB container is not running), a warning is printed and the script continues with the next folder.

### Requirements

- **bash**, **docker**
- `.env` in each folder (for Postgres credentials when not in compose)
- Containers must be running for `docker exec` backup

### Other scripts

- **backup-pre-script.sh** / **backup-post-script.sh** – Used by [tiredofit/docker-db-backup](https://github.com/tiredofit/docker-db-backup) in some stacks (e.g. miniflux, pocket-id) for pre/post backup hooks.
