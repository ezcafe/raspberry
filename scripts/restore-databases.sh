#!/usr/bin/env bash
#
# Restore databases (Postgres and SQLite) from backup files into docker-compose stacks.
# For each folder/backup pair: finds the folder by name, reads .env and docker-compose,
# detects DB type, and restores the given backup file into that database.
#
# Usage: restore-databases.sh FOLDER_NAMES BACKUP_FILES
#   FOLDER_NAMES   - Comma-separated folder names (e.g. sure,miniflux)
#   BACKUP_FILES   - Comma-separated paths to backup .sql files (same order as FOLDER_NAMES)
#
# Example: restore-databases.sh "sure,miniflux" "/home/ezcafe/backups/sure/sure_20260218.sql,/home/ezcafe/backups/miniflux/miniflux_20260218.sql"
#
# Requires: docker, bash. Backup files must be plain SQL (as produced by backup-databases.sh).

set -euo pipefail

# --- config ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- helpers ---
log() { echo "[restore] $*" >&2; }
warn() { echo "[restore] WARNING: $*" >&2; }
err()  { echo "[restore] ERROR: $*" >&2; }

find_folder_by_name() {
  local name="$1"
  find "$ROOT_DIR" -maxdepth 3 -type d -name "$name" 2>/dev/null | head -n1
}

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

parse_postgres() {
  local dir="$1"
  local compose="$dir/docker-compose.yml"
  if [[ ! -f "$compose" ]]; then
    return 1
  fi

  local resolved
  resolved=$(cd "$dir" && docker compose config 2>/dev/null) || return 1

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
      sub(/^[^:]+:[[:space:]]*/, "")
      sub(/[[:space:]]*$/, "")
      gsub(/"/, "")
      container = $0
      next
    }
    in_svc && /^      POSTGRES_DB:/ {
      sub(/^[^:]+:[[:space:]]*/, "")
      sub(/[[:space:]]*$/, "")
      gsub(/"/, "")
      postgres_db = $0
      next
    }
    in_svc && /^      POSTGRES_USER:/ {
      sub(/^[^:]+:[[:space:]]*/, "")
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
    [[ -n "${DB_NAME:-}" ]] && [[ -n "${DB_USER:-}" ]] && return 0
  fi
  return 1
}

parse_sqlite() {
  local dir="$1"
  local compose="$dir/docker-compose.yml"
  if [[ ! -f "$compose" ]]; then
    return 1
  fi
  local in_service="" container_name=""
  local db01_type="" db01_host=""

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^[[:space:]]*([a-zA-Z0-9_.-]+):[[:space:]]*$ ]]; then
      if [[ -n "$in_service" ]] && [[ "$db01_type" == "sqlite3" ]] && [[ -n "$db01_host" ]]; then
        CONTAINER="${container_name:-}"
        DB_PATH="${db01_host:-}"
        [[ -z "${CONTAINER:-}" ]] && CONTAINER="${in_service:-}"
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
    CONTAINER="${container_name:-}"
    DB_PATH="${db01_host:-}"
    [[ -z "${CONTAINER:-}" ]] && CONTAINER="${in_service:-}"
    return 0
  fi
  return 1
}

restore_postgres() {
  local container="$1" dbname="$2" user="$3" backup_file="$4"
  log "POSTGRES: Restoring $backup_file into $container ($dbname)"
  if [[ ! -f "$backup_file" ]]; then
    err "Backup file not found: $backup_file"
    return 1
  fi
  if ! docker ps --format '{{.Names}}' | grep -qx "$container" 2>/dev/null; then
    err "Container not running: $container"
    return 1
  fi
  docker exec -i "$container" psql -U "$user" -d "$dbname" < "$backup_file"
  log "Restored $container ($dbname)."
}

restore_sqlite() {
  local container="$1" db_path="$2" backup_file="$3"
  log "SQLITE: Restoring $backup_file into $container ($db_path)"
  if [[ ! -f "$backup_file" ]]; then
    err "Backup file not found: $backup_file"
    return 1
  fi
  if ! docker ps --format '{{.Names}}' | grep -qx "$container" 2>/dev/null; then
    err "Container not running: $container"
    return 1
  fi
  # SQLite: remove existing DB then feed dump so we get a clean replace
  docker exec "$container" rm -f "$db_path" 2>/dev/null || true
  docker exec -i "$container" sqlite3 "$db_path" < "$backup_file"
  log "Restored $container ($db_path)."
}

# --- main ---
main() {
  local folder_names="${1:-}"
  local backup_files="${2:-}"

  if [[ -z "$folder_names" ]] || [[ -z "$backup_files" ]]; then
    err "Usage: $0 FOLDER_NAMES BACKUP_FILES"
    err "  FOLDER_NAMES  - Comma-separated folder names (e.g. sure,miniflux)"
    err "  BACKUP_FILES  - Comma-separated paths to backup .sql files (same order)"
    err "  Example: $0 \"sure,miniflux\" \"/path/to/sure.sql,/path/to/miniflux.sql\""
    exit 1
  fi

  log "Started at $(date '+%Y-%m-%d %H:%M:%S')"
  IFS=',' read -ra NAMES <<< "$folder_names"
  IFS=',' read -ra FILES <<< "$backup_files"

  if [[ ${#NAMES[@]} -ne ${#FILES[@]} ]]; then
    err "FOLDER_NAMES and BACKUP_FILES must have the same number of comma-separated entries (got ${#NAMES[@]} vs ${#FILES[@]})"
    exit 1
  fi

  for i in "${!NAMES[@]}"; do
    local name="${NAMES[i]}"
    name=$(echo "$name" | tr -d '[:space:]')
    local backup_file="${FILES[i]}"
    backup_file=$(echo "$backup_file" | tr -d '[:space:]')
    # Expand leading ~
    backup_file="${backup_file/#\~/$HOME}"

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
          DB_USERNAME DB_DATABASE DB_DATABASE_NAME CONTAINER DB_PATH
    load_env "$dir"
    local did_restore=false

    CONTAINER=""
    if parse_postgres "$dir"; then
      [[ -z "${DB_NAME:-}" ]] && DB_NAME="${POSTGRES_DB:-${DB_DATABASE_NAME:-${DB_DATABASE:-}}}"
      [[ -z "${DB_USER:-}" ]] && DB_USER="${POSTGRES_USER:-${DB_USERNAME:-}}"
      if [[ -z "${CONTAINER:-}" ]]; then
        local cid
        cid=$(cd "$dir" && docker compose ps -q db 2>/dev/null) || true
        if [[ -n "$cid" ]]; then
          CONTAINER=$(docker inspect -f '{{.Name}}' "$cid" 2>/dev/null | tr -d '/')
        fi
      fi
      [[ -z "${CONTAINER:-}" ]] && CONTAINER="${name}-db"
      if [[ -n "${DB_NAME:-}" ]] && [[ -n "${DB_USER:-}" ]]; then
        restore_postgres "${CONTAINER:-}" "${DB_NAME:-}" "${DB_USER:-}" "$backup_file" && did_restore=true
      else
        warn "Postgres found in $name but DB_NAME or DB_USER missing (skipping)"
        warn "  Supported env patterns: DB_NAME, DB_USER, POSTGRES_DB, POSTGRES_USER, DB_USERNAME, DB_DATABASE, DB_DATABASE_NAME"
      fi
    fi

    if [[ "$did_restore" != true ]]; then
      CONTAINER="" DB_PATH=""
      if parse_sqlite "$dir"; then
        restore_sqlite "${CONTAINER:-}" "${DB_PATH:-}" "$backup_file" && did_restore=true
      fi
    fi

    if [[ "$did_restore" != true ]]; then
      warn "No database found (or restore failed) for $name"
    fi
  done

  log "Done."
}

main "$@"
