#!/usr/bin/env bash

DIR="$(dirname "$0")"
USER="${POSTGRES_USER:-dbt}"
DB="${POSTGRES_DB:-dbt}"

docker exec -i dbt-postgres psql -U "$USER" -d "$DB" < "$DIR/01_create_relations.sql"
docker exec -i dbt-postgres psql -U "$USER" -d "$DB" < "$DIR/02_generate_relations_data.sql"
docker exec -i dbt-postgres psql -U "$USER" -d "$DB" < "$DIR/03_create_orders.sql"
docker exec -i dbt-postgres psql -U "$USER" -d "$DB" < "$DIR/04_generate_orders_data.sql"
