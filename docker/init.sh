#!/bin/sh
# Runs once when the container is created: schema + demo data + tests.
set -e
cd /canchaya
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f install.sql
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -f tests/test_business_rules.sql
