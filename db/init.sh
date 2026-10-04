#!/bin/sh
# Creates the per-service roles and schemas. Needs PG* (or the postgres image's
# POSTGRES_* inside its entrypoint) plus CATALOG_DB_PASSWORD, ORDERS_DB_PASSWORD
# and NOTIFICATION_DB_PASSWORD.
set -eu
here="$(cd "$(dirname "$0")" && pwd)"
psql -v ON_ERROR_STOP=1 \
  --username "${PGUSER:-${POSTGRES_USER:-postgres}}" \
  --dbname "${PGDATABASE:-${POSTGRES_DB:-postgres}}" \
  -v catalog_password="$CATALOG_DB_PASSWORD" \
  -v orders_password="$ORDERS_DB_PASSWORD" \
  -v notification_password="$NOTIFICATION_DB_PASSWORD" \
  -f "${SCHEMAS_SQL:-$here/schemas.sql}"
