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

# Get env value from compose line (for parse_sqlite). Expands ${VAR}; use set +u to avoid unbound error.
get_env_value() {
  local line="$1" key="$2"
  local pattern="^[[:space:]]*-[[:space:]]*${key}=.*"
  [[ ! "$line" =~ $pattern ]] && return
  local raw
  raw=$(echo "$line" | sed -E "s/^[[:space:]]*-[[:space:]]*${key}=//" | tr -d '\r')
  if [[ "$raw" =~ ^\$\{([^}]+)\}$ ]]; then
    local var_name="${BASH_REMATCH[1]}"
    set +u
    echo "${!var_name:-}"
    set -u
  else
    echo "$raw"
  fi
}

# Parse docker-compose in $1 (dir) using `docker compose config` for fully resolved values.
# Sets globals: CONTAINER, DB_NAME, DB_USER. Returns 0 if postgres found, 1 otherwise.
# Uses resolved config so YAML anchors, .env, env_file all work correctly.
parse_postgres() {
  local dir="$1"
  local compose="$dir/docker-compose.yml"
  if [[ ! -f "$compose" ]]; then
    return 1
  fi

  local resolved
  resolved=$(cd "$dir" && docker compose config 2>/dev/null) || return 1

  # Find any service block with image: postgres
  local db_block
  db_block=$(echo "$resolved" | awk '
    /^  [a-zA-Z0-9_.-]+:$/ {
      in_svc = 1
      container = ""
      postgres_db = ""
      postgres_user = ""
      next
    }
    in_svc && /^    container_name:/ {
      sub(/.*container_name:[[:space:]]*/, "")
      sub(/[[:space:]]*$/, "")
      gsub(/"/, "")
      container = $0
      next
    }
    in_svc && /^      POSTGRES_DB:/ {
      sub(/.*POSTGRES_DB:[[:space:]]*/, "")
      sub(/[[:space:]]*$/, "")
      gsub(/"/, "")
      postgres_db = $0
      next
    }
    in_svc && /^      POSTGRES_USER:/ {
      sub(/.*POSTGRES_USER:[[:space:]]*/, "")
      sub(/[[:space:]]*$/, "")
      gsub(/"/, "")
      postgres_user = $0
      next
    }
    in_svc && /image:.*postgres/ {
      if (postgres_db && postgres_user) {
        print "CONTAINER=" container
        print "DB_NAME=" postgres_db
        print "DB_USER=" postgres_user
        exit 0
      }
    }
  ')

  if [[ -n "$db_block" ]]; then
    eval "$db_block"
    CONTAINER="${CONTAINER:-}"
    DB_NAME="${DB_NAME:-}"
    DB_USER="${DB_USER:-}"
    [[ -n "$DB_NAME" ]] && [[ -n "$DB_USER" ]] && return 0
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

    # Try Postgres first (parse_postgres uses docker compose config for resolved values)
    CONTAINER=""
    if parse_postgres "$dir"; then
      # Fallback when docker compose config misses values (e.g. non-standard setup)
      [[ -z "${DB_NAME:-}" ]] && DB_NAME="${POSTGRES_DB:-${DB_DATABASE_NAME:-${DB_DATABASE:-}}}"
      [[ -z "${DB_USER:-}" ]] && DB_USER="${POSTGRES_USER:-${DB_USERNAME:-}}"
      if [[ -z "${CONTAINER:-}" ]]; then
        cid=$(cd "$dir" && docker compose ps -q db 2>/dev/null) || true
        if [[ -n "$cid" ]]; then
          CONTAINER=$(docker inspect -f '{{.Name}}' "$cid" 2>/dev/null | tr -d '/')
        fi
      fi
      [[ -z "${CONTAINER:-}" ]] && CONTAINER="${name}-db"
      if docker ps --format '{{.Names}}' | grep -qx "${CONTAINER:-}" 2>/dev/null; then
        if [[ -n "${DB_NAME:-}" ]] && [[ -n "${DB_USER:-}" ]]; then
          backup_postgres "$CONTAINER" "$DB_NAME" "$DB_USER" "$out_file"
          did_backup=true
        else
          warn "Postgres found in $name but DB_NAME or DB_USER missing in .env/compose (skipping)"
          warn "  Supported env patterns: DB_NAME, DB_USER, POSTGRES_DB, POSTGRES_USER, DB_USERNAME, DB_DATABASE, DB_DATABASE_NAME"
        fi
      else
        warn "Postgres container '${CONTAINER:-}' not running in $name (skipping)"
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
