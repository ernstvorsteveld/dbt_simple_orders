# Database

## Start PostgreSQL

Starts the PostgreSQL 17 container (`dbt-postgres`) in the background. You can start the database using any of the following options:
1. **Environment variables** — export `POSTGRES_*` variables in your shell session before starting.
2. **Inline command-line variables** — pass `POSTGRES_*` values directly on the `docker compose up -d` command.
3. **`.env` file** — define `POSTGRES_*` values in a `.env` file in the project root.
4. **Default settings** — run `docker compose up -d` directly without setting any variables.

Default settings in `docker-compose.yml`:
- **User** (`POSTGRES_USER`): `dbt`
- **Password** (`POSTGRES_PASSWORD`): `dbt`
- **Database** (`POSTGRES_DB`): `dbt`
- **Port** (`POSTGRES_PORT`): `5432`

*(Note: if the `postgres_data` volume was already created, recreate it with `docker compose down -v` so PostgreSQL applies a new user, password, or database.)*

1. Set via environment variables:
```bash
export POSTGRES_USER=myuser
export POSTGRES_PASSWORD=mypassword
export POSTGRES_DB=mydb
export POSTGRES_PORT=5433
docker compose up -d
```

2. Pass inline on the command line:
```bash
POSTGRES_USER=myuser POSTGRES_PASSWORD=mypassword POSTGRES_DB=mydb POSTGRES_PORT=5433 docker compose up -d
```

3. Set via a `.env` file in the project root:
```dotenv
# .env
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypassword
POSTGRES_DB=mydb
POSTGRES_PORT=5433
```
```bash
docker compose up -d
```

4. Start with defaults:
```bash
docker compose up -d
```

## Create Tables and Load Data

Executes the numbered SQL scripts in `db/` inside the `dbt-postgres` container to create the `raw` schema (`raw.relations`, `raw.orders`, `raw.order_items`) and load the generated data. You can run the scripts using any of the following options:
1. **Environment variables** — export `POSTGRES_USER` and `POSTGRES_DB` in your shell before running `db/run_sql.sh`.
2. **Inline command-line variables** — pass `POSTGRES_USER` and `POSTGRES_DB` inline to `db/run_sql.sh`.
3. **Individual SQL script** — execute a single SQL file manually via `docker exec`.
4. **Default settings** — run `./db/run_sql.sh` directly.

Default settings in `db/run_sql.sh`:
- **Container**: `dbt-postgres`
- **User** (`POSTGRES_USER`): `dbt`
- **Database** (`POSTGRES_DB`): `dbt`

*(Note: all SQL scripts are idempotent and safe to re-run.)*

1. Set via environment variables:
```bash
export POSTGRES_USER=myuser
export POSTGRES_DB=mydb
./db/run_sql.sh
```

2. Pass inline on the command line:
```bash
POSTGRES_USER=myuser POSTGRES_DB=mydb ./db/run_sql.sh
```

3. Run an individual SQL script:
```bash
docker exec -i dbt-postgres psql -U dbt -d dbt < db/01_create_relations.sql
```

4. Run all scripts with defaults:
```bash
./db/run_sql.sh
```
