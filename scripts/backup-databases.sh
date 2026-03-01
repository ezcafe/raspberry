#!/usr/bin/env bash
#
# Backup databases (Postgres and SQLite) from docker-compose stacks in named folders.
# For each folder: finds the folder by name, reads .env, detects DB from docker-compose,
# and writes backup to destination/foldername/foldername_YYYYMMDD-HHMMSS.sql
#
# Usage: backup-databases.sh FOLDER_NAMES DESTINATION_PATH
#   FOLDER_NAMES  - Comma-separated folder names (e.g. miniflux,pocket-id)
#   DESTINATION_PATH - Base path for backups (e.g. ~/backups)
#
# Example: backup-databases.sh miniflux,pocket-id ~/backups
#   Creates ~/backups/miniflux/miniflux_20260215-143022.sql and
#   ~/backups/pocket-id/pocket-id_20260215-143022.sql
#
# Requires: docker, bash, sqlite3 (for local sqlite; for Docker SQLite we use exec).
# Optional: zstd for compression (not used by default to keep portability).

set -euo pipefail

# --- config ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Search for folders under this directory's parent (workspace root when run from scripts/)
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DATETIME="$(date +%Y%m%d-%H%M%S)"

# --- helpers ---
log() { echo "[backup] $*" >&2; }
warn() { echo "[backup] WARNING: $*" >&2; }
err()  { echo "[backup] ERROR: $*" >&2; }

# Find a directory under ROOT_DIR whose name is exactly $1 (first match).
find_folder_by_name() {
  local name="$1"
  find "$ROOT_DIR" -maxdepth 3 -type d -name "$name" 2>/dev/null | head -n1
}

# Load .env into current shell (export KEY=value). No quotes in value supported.
load_env() {
  local dir="$1"
  local env_file="$dir/.env"
  if [[ ! -f "$env_file" ]]; then
    return 0
  fi
  set -a
  # shellcheck source=/dev/null
  source "$env_file" 2>/dev/null || true
  set +a
}

# Get the value of a variable from a compose env line after substitution.
# Line format: "      - POSTGRES_DB=${POSTGRES_DB}" or "      - POSTGRES_DB=value"
get_env_value() {
  local line="$1"
  local key="$2"
  local pattern="^[[:space:]]*-[[:space:]]*${key}=.*"
  if [[ ! "$line" =~ $pattern ]]; then
    return
  fi
  local raw
  raw=$(echo "$line" | sed -E "s/^[[:space:]]*-[[:space:]]*${key}=//" | tr -d '\r')
  if [[ "$raw" =~ ^\$\{([^}]+)\}$ ]]; then
    local var_name="${BASH_REMATCH[1]}"
    echo "${!var_name:-}"
  else
    echo "$raw"
  fi
}

# Parse docker-compose in $1 (dir) and set globals for postgres: CONTAINER, DB_NAME, DB_USER.
# Returns 0 if postgres found, 1 otherwise.
parse_postgres() {
  local dir="$1"
  local compose="$dir/docker-compose.yml"
  if [[ ! -f "$compose" ]]; then
    return 1
  fi
  local in_service="" service_name="" image="" container_name=""
  local postgres_db="" postgres_user=""
  local db_name_key="" db_user_key=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_.-]+):[[:space:]]*$ ]]; then
      if [[ -n "$in_service" ]]; then
        # End of previous service block; check if it was postgres
        if [[ "$image" == *"postgres"* ]]; then
          CONTAINER="$container_name"
          # Prefer POSTGRES_* then DB_*
          [[ -n "$postgres_db" ]] && DB_NAME="$postgres_db"
          [[ -n "$postgres_user" ]] && DB_USER="$postgres_user"
          return 0
        fi
      fi
      in_service="${BASH_REMATCH[1]}"
      service_name="$in_service"
      image=""
      container_name=""
      postgres_db=""
      postgres_user=""
    elif [[ -n "$in_service" ]]; then
      if [[ "$line" =~ ^[[:space:]]*image:[[:space:]]*(.+)$ ]]; then
        image="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^[[:space:]]*container_name:[[:space:]]*(.+)$ ]]; then
        container_name="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*POSTGRES_DB= ]]; then
        postgres_db=$(get_env_value "$line" "POSTGRES_DB")
      elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*POSTGRES_USER= ]]; then
        postgres_user=$(get_env_value "$line" "POSTGRES_USER")
      elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*DB_NAME= ]]; then
        postgres_db=$(get_env_value "$line" "DB_NAME")
      elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*DB_USER= ]]; then
        postgres_user=$(get_env_value "$line" "DB_USER")
      elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*DB_DATABASE_NAME= ]]; then
        postgres_db=$(get_env_value "$line" "DB_DATABASE_NAME")
      elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*DB_DATABASE= ]]; then
        postgres_db=$(get_env_value "$line" "DB_DATABASE")
      elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*DB_USERNAME= ]]; then
        postgres_user=$(get_env_value "$line" "DB_USERNAME")
      fi
    fi
  done < "$compose"

  if [[ -n "$in_service" ]] && [[ "$image" == *"postgres"* ]]; then
    CONTAINER="$container_name"
    [[ -n "$postgres_db" ]] && DB_NAME="$postgres_db"
    [[ -n "$postgres_user" ]] && DB_USER="$postgres_user"
    [[ -z "$CONTAINER" ]] && CONTAINER="${in_service}"
    return 0
  fi
  return 1
}

# Parse docker-compose for SQLite (service with DB01_TYPE=sqlite3). Sets CONTAINER and DB_PATH.
parse_sqlite() {
  local dir="$1"
  local compose="$dir/docker-compose.yml"
  if [[ ! -f "$compose" ]]; then
    return 1
  fi
  local in_service="" image="" container_name=""
  local db01_type="" db01_host=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_.-]+):[[:space:]]*$ ]]; then
      if [[ -n "$in_service" ]] && [[ "$db01_type" == "sqlite3" ]] && [[ -n "$db01_host" ]]; then
        CONTAINER="$container_name"
        DB_PATH="$db01_host"
        [[ -z "$CONTAINER" ]] && CONTAINER="${in_service}"
        return 0
      fi
      in_service="${BASH_REMATCH[1]}"
      container_name=""
      db01_type=""
      db01_host=""
    elif [[ -n "$in_service" ]]; then
      if [[ "$line" =~ ^[[:space:]]*container_name:[[:space:]]*(.+)$ ]]; then
        container_name="${BASH_REMATCH[1]}"
      elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*DB01_TYPE= ]]; then
        db01_type=$(get_env_value "$line" "DB01_TYPE")
      elif [[ "$line" =~ ^[[:space:]]*-[[:space:]]*DB01_HOST= ]]; then
        db01_host=$(get_env_value "$line" "DB01_HOST")
      fi
    fi
  done < "$compose"

  if [[ -n "$in_service" ]] && [[ "$db01_type" == "sqlite3" ]] && [[ -n "$db01_host" ]]; then
    CONTAINER="$container_name"
    DB_PATH="$db01_host"
    [[ -z "$CONTAINER" ]] && CONTAINER="${in_service}"
    return 0
  fi
  return 1
}

backup_postgres() {
  local container="$1" dbname="$2" user="$3" out_file="$4"
  log "POSTGRES: Backing up $container ($dbname) to $out_file"
  if docker exec "$container" pg_dump "$dbname" -U "$user" > "$out_file"; then
    log "Wrote $(wc -l < "$out_file") lines to $out_file"
  else
    err "pg_dump failed for $container"
    return 1
  fi
}

backup_sqlite() {
  local container="$1" db_path="$2" out_file="$3"
  log "SQLITE: Backing up $container ($db_path) to $out_file"
  if docker exec "$container" sqlite3 "$db_path" .dump > "$out_file"; then
    log "Wrote $(wc -l < "$out_file") lines to $out_file"
  else
    err "sqlite3 dump failed for $container"
    return 1
  fi
}

# --- main ---
main() {
  local folder_names="${1:-}"
  local destination="${2:-}"

  if [[ -z "$folder_names" ]] || [[ -z "$destination" ]]; then
    err "Usage: $0 FOLDER_NAMES DESTINATION_PATH"
    err "  Example: $0 miniflux,pocket-id ~/backups"
    exit 1
  fi

  destination="${destination/#\~/$HOME}"
  if [[ ! -d "$destination" ]]; then
    mkdir -p "$destination"
    log "Created destination $destination"
  fi

  IFS=',' read -ra NAMES <<< "$folder_names"
  for name in "${NAMES[@]}"; do
    name=$(echo "$name" | tr -d '[:space:]')
    [[ -z "$name" ]] && continue

    local dir
    dir=$(find_folder_by_name "$name")
    if [[ -z "$dir" ]]; then
      warn "Folder not found: $name (skipping)"
      continue
    fi

    local compose="$dir/docker-compose.yml"
    if [[ ! -f "$compose" ]]; then
      warn "No docker-compose.yml in $dir (skipping)"
      continue
    fi

    # Clear DB vars so we don't inherit from previous folder
    unset DB_NAME DB_USER DB_HOST DB_PASS POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD \
          DB_USERNAME DB_DATABASE DB_DATABASE_NAME
    load_env "$dir"
    local out_dir="$destination/$name"
    mkdir -p "$out_dir"
    local out_file="$out_dir/${name}_${DATETIME}.sql"
    local did_backup=false

    # Try Postgres first (keep DB_NAME/DB_USER from load_env so get_env_value can expand ${DB_NAME} etc.)
    CONTAINER=""
    if parse_postgres "$dir"; then
      # Fallback to .env when compose uses env_file or different var names
      [[ -z "$DB_NAME" ]] && DB_NAME="${POSTGRES_DB:-${DB_DATABASE_NAME:-${DB_DATABASE:-}}}"
      [[ -z "$DB_USER" ]] && DB_USER="${POSTGRES_USER:-${DB_USERNAME:-}}"
      if [[ -z "$CONTAINER" ]]; then
        cid=$(cd "$dir" && docker compose ps -q db 2>/dev/null) || true
        if [[ -n "$cid" ]]; then
          CONTAINER=$(docker inspect -f '{{.Name}}' "$cid" 2>/dev/null | tr -d '/')
        fi
      fi
      [[ -z "$CONTAINER" ]] && CONTAINER="${name}-db"
      if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER" 2>/dev/null; then
      if [[ -n "$DB_NAME" ]] && [[ -n "$DB_USER" ]]; then
        backup_postgres "$CONTAINER" "$DB_NAME" "$DB_USER" "$out_file"
        did_backup=true
      else
        warn "Postgres found in $name but DB_NAME or DB_USER missing in .env/compose (skipping)"
        warn "  Supported env patterns: DB_NAME, DB_USER, POSTGRES_DB, POSTGRES_USER, DB_USERNAME, DB_DATABASE, DB_DATABASE_NAME"
      fi
    else
      warn "Postgres container '$CONTAINER' not running in $name (skipping)"
    fi
  fi

    # Try SQLite if no postgres
    if [[ "$did_backup" != true ]]; then
      CONTAINER="" DB_PATH=""
      if parse_sqlite "$dir"; then
        if docker ps --format '{{.Names}}' | grep -qx "$CONTAINER" 2>/dev/null; then
          backup_sqlite "$CONTAINER" "$DB_PATH" "$out_file"
          did_backup=true
        else
          warn "SQLite container '$CONTAINER' not running in $name (skipping)"
        fi
      fi
    fi

    if [[ "$did_backup" != true ]]; then
      warn "No database found (or container not running) in $name"
    fi
  done

  log "Done."
}

main "$@"
