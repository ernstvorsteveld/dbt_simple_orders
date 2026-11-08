# dbt ETL

PostgreSQL + dbt analytics project transforming `raw` relational data into `staging` views, `marts` star-schema (`dim_*` / `fct_*`) tables, and `reporting` (`rpt_*`) output tables.

## Quick Start

1. Start PostgreSQL:
   ```bash
   docker compose up -d
   ```
2. Create the `raw` schema/tables and load seed data:
   ```bash
   ./db/run_sql.sh
   ```
3. Build all dbt layers (`staging` → `marts` → `reporting`):
   ```bash
   .venv/bin/dbt run --project-dir etl --profiles-dir etl
   ```
4. Inspect the reporting output table:
   ```bash
   docker exec -i dbt-postgres psql -U dbt -d dbt -c "SELECT * FROM reporting.rpt_weekly_orders LIMIT 10;"
   ```

## Documentation

- [Database Setup & Seed Data](docs/database.md) — Start the PostgreSQL 17 container and load the `raw` schema and generated data.
- [Running dbt](docs/dbt.md) — Configure connection settings and build the `staging`, `marts`, and `reporting` layers.
- [Data Model](docs/data_model.md) — Schema layers, view vs. table materializations, `dim_*`, `fct_*`, and `rpt_*` design, key conventions, and example queries.

## Agent Rules

- [General Rules](AGENTS.md) — Version control, local installation boundaries, and scope rules.
- [Database Rules](.agents/rules/database.md) — Idempotent SQL scripts, schema separation, and `psql` execution rules.
- [dbt Rules](.agents/rules/dbt.md) — Primary key (`id`) and foreign key (`<entity>_id`) naming conventions.
- [Documentation Rules](.agents/rules/documentation.md) — Required structure for documentation sections.
