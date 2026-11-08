WITH weekly_agg AS (
    SELECT
        EXTRACT(ISOYEAR FROM d.date_day)::int AS year,
        d.iso_week AS week,
        o.currency_code,
        o.order_status,
        COUNT(*)::int AS order_count,
        SUM(o.line_count)::int AS order_line_count,
        SUM(o.total_amount)::numeric(14, 2) AS total_order_amount
    FROM {{ ref('fct_orders') }} AS o
    INNER JOIN {{ ref('dim_dates') }} AS d
        ON d.id = o.order_date_id
    GROUP BY
        EXTRACT(ISOYEAR FROM d.date_day)::int,
        d.iso_week,
        o.currency_code,
        o.order_status
)
SELECT
    ROW_NUMBER() OVER (
        ORDER BY year, week, currency_code, order_status
    )::bigint AS id,
    year,
    week,
    currency_code,
    order_status,
    order_count,
    order_line_count,
    total_order_amount
FROM weekly_agg
