#!/bin/sh
# Proves each service role can't read another service's schema (acceptance J7).
# Usage: PGHOST=... PGPORT=... PGDATABASE=... CATALOG_DB_PASSWORD=... ORDERS_DB_PASSWORD=... db/check-boundaries.sh
set -u
fail=0
try() { # role password schema.table
  if PGPASSWORD="$2" psql -X -q -U "$1" -c "select 1 from $3 limit 1" >/dev/null 2>&1; then
    echo "FAIL: $1 can read $3"; fail=1
  else
    echo "ok:   $1 cannot read $3"
  fi
}
try catalog_svc "$CATALOG_DB_PASSWORD" orders.orders
try catalog_svc "$CATALOG_DB_PASSWORD" notification.notifications
try orders_svc "$ORDERS_DB_PASSWORD" catalog.products
try orders_svc "$ORDERS_DB_PASSWORD" notification.notifications
try notification_svc "$NOTIFICATION_DB_PASSWORD" orders.orders
try notification_svc "$NOTIFICATION_DB_PASSWORD" catalog.products
exit $fail
