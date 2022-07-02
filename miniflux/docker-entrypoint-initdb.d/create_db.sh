#!/bin/bash
set -e

POSTGRES="psql --username ${DB_USER}"

echo "Creating database: ${DB_NAME}"

$POSTGRES <<EOSQL
CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};
EOSQL