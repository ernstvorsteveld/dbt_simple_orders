---
trigger: always_on
---

# dbt Rules

- **Primary and foreign key naming:** Every dbt model across `staging`, `marts`, and `reporting` must expose its own primary key as `id` — renaming existing primary keys (e.g., `order_id AS id`) and generating deterministic integer `id` keys for derived dimensions or aggregated tables without a source ID (e.g., `ROW_NUMBER()` on `dim_products` and `rpt_*`, `YYYYMMDD` integer on `dim_dates`). Name all foreign keys `<entity>_id` (or `<role>_<entity>_id` for role-playing references such as `order_date_id`, `shipped_date_id`, `delivered_date_id`), linking facts to dimensions via `*_id` rather than natural keys (`sku`, `date_day`). Keep `raw` source column names unchanged.
- **Confirm exact columns and names before writing models:** Never add unrequested columns, helper attributes, or naming prefixes (for example, `week_start_date`, disambiguating columns like `year`, or `iso_` prefixes) to a dbt model on your own. Whenever a model requires or benefits from any column or column name not explicitly specified by the user, list the exact proposed columns and ask for confirmation before writing the SQL.
