WITH date_bounds AS (
    SELECT
        COALESCE(DATE_TRUNC('year', MIN(min_ts))::date, DATE '2025-01-01') AS start_date,
        COALESCE(
            (DATE_TRUNC('year', MAX(max_ts)) + INTERVAL '1 year - 1 day')::date,
            DATE '2026-12-31'
        ) AS end_date
    FROM (
        SELECT MIN(created_at) AS min_ts, MAX(updated_at) AS max_ts
        FROM {{ ref('stg_relations') }}
        UNION ALL
        SELECT
            MIN(ordered_at) AS min_ts,
            MAX(GREATEST(ordered_at, COALESCE(delivered_at, shipped_at, ordered_at), updated_at)) AS max_ts
        FROM {{ ref('stg_orders') }}
    ) AS s
),
calendar AS (
    SELECT generate_series(start_date, end_date, INTERVAL '1 day')::date AS date_day
    FROM date_bounds
)
SELECT
    TO_CHAR(date_day, 'YYYYMMDD')::int AS id,
    date_day,
    EXTRACT(YEAR FROM date_day)::int AS year,
    EXTRACT(QUARTER FROM date_day)::int AS quarter,
    EXTRACT(MONTH FROM date_day)::int AS month,
    TO_CHAR(date_day, 'FMMonth') AS month_name,
    EXTRACT(WEEK FROM date_day)::int AS iso_week,
    EXTRACT(DAY FROM date_day)::int AS day_of_month,
    EXTRACT(ISODOW FROM date_day)::int AS day_of_week,
    TO_CHAR(date_day, 'FMDay') AS day_name,
    (EXTRACT(ISODOW FROM date_day) IN (6, 7)) AS is_weekend
FROM calendar
