# dbt

## Run dbt

Runs the `etl` dbt project using the local `.venv` and `etl/profiles.yml` to transform `raw` sources into `staging` views (`stg_relations`, `stg_orders`, `stg_order_items`), `marts` dimension/fact tables (`dim_relations`, `dim_products`, `dim_dates`, `fct_orders`, `fct_order_items`), and `reporting` output tables (`rpt_weekly_orders`). You can configure and execute dbt using any of the following options:
1. **Environment variables** — export `POSTGRES_*` variables in your shell before running dbt.
2. **Inline command-line variables** — pass `POSTGRES_*` values directly on the dbt command.
3. **Specific layer or model** — pass `--select staging`, `--select marts`, or `--select reporting` to build a single layer.
4. **From inside `etl/`** — change into `etl/` so dbt automatically discovers `dbt_project.yml` and `profiles.yml`.
5. **Default settings from the project root** — pass `--project-dir etl --profiles-dir etl` without setting any variables.

Default settings in `etl/profiles.yml` (`dev` target) and `etl/dbt_project.yml`:
- **Host** (`POSTGRES_HOST`): `localhost`
- **Port** (`POSTGRES_PORT`): `5432`
- **User** (`POSTGRES_USER`): `dbt`
- **Password** (`POSTGRES_PASSWORD`): `dbt`
- **Database** (`POSTGRES_DB`): `dbt`
- **Fallback schema** (`POSTGRES_SCHEMA`): `public`
- **Staging schema** (`models/staging/`): `staging` (materialized as `view`)
- **Marts schema** (`models/marts/`): `marts` (materialized as `table`)
- **Reporting schema** (`models/reporting/`): `reporting` (materialized as `table`)

*(Note: when running from the project root, always include `--profiles-dir etl` so dbt uses the project-local profile instead of `~/.dbt/`. Custom schemas are resolved directly to `staging`, `marts`, and `reporting` via `etl/macros/generate_schema_name.sql` rather than being prefixed with `POSTGRES_SCHEMA`.)*

1. Set via environment variables:
```bash
export POSTGRES_HOST=localhost
export POSTGRES_PORT=5433
export POSTGRES_USER=myuser
export POSTGRES_PASSWORD=mypassword
export POSTGRES_DB=mydb
export POSTGRES_SCHEMA=analytics
.venv/bin/dbt run --project-dir etl --profiles-dir etl
```

2. Pass inline on the command line:
```bash
POSTGRES_USER=myuser POSTGRES_PASSWORD=mypassword POSTGRES_DB=mydb POSTGRES_PORT=5433 POSTGRES_SCHEMA=analytics .venv/bin/dbt run --project-dir etl --profiles-dir etl
```

3. Run a single layer (`staging`, `marts`, or `reporting`):
```bash
.venv/bin/dbt run --project-dir etl --profiles-dir etl --select staging
.venv/bin/dbt run --project-dir etl --profiles-dir etl --select marts
.venv/bin/dbt run --project-dir etl --profiles-dir etl --select reporting
```

4. Run from inside `etl/`:
```bash
cd etl
../.venv/bin/dbt run
```

5. Run with defaults from the project root:
```bash
.venv/bin/dbt debug --project-dir etl --profiles-dir etl
.venv/bin/dbt run --project-dir etl --profiles-dir etl
```
