#!/bin/sh
# Runs once when the local postgres container initialises its data directory.
SCHEMAS_SQL=/wmd/schemas.sql exec /wmd/init.sh
