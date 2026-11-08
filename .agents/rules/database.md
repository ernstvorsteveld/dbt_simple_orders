---
trigger: always_on
---

# Database Rules

- **No implicit SQL or script execution:** Never configure automatic or implicit execution of database DDL, seed data, or shell scripts (for example, never mount scripts into `/docker-entrypoint-initdb.d`, container startup hooks, or auto-init entrypoints). All schema creation and data generation scripts must be executed explicitly via dedicated scripts or manual commands.
- **Idempotent SQL scripts:** Every DDL and data script in `db/` must be safe to re-run without errors (use `IF NOT EXISTS` and `ON CONFLICT ... DO NOTHING`), since `db/run_sql.sh` executes all scripts sequentially.
- **Schema separation (`raw` vs. dbt):** Source tables belong strictly in the `raw` schema (managed via `db/*.sql`), while transformed tables and views are managed strictly by dbt (never write dbt models into `raw` or manual DDL into dbt schemas).
- **Numbered SQL files in `db/`:** Name SQL scripts with ordered numeric prefixes (`01_`, `02_`, ...) to reflect execution order, and add any new SQL scripts to `db/run_sql.sh`.
- **Container-based `psql` execution:** Execute SQL via `docker exec -i dbt-postgres psql ...` rather than assuming `psql` is installed on the host machine.
- **No destructive commands without approval:** Never run `DROP`, `TRUNCATE`, or `docker compose down -v` unless explicitly requested by the user.
