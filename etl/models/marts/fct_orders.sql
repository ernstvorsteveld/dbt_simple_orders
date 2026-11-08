WITH item_rollup AS (
    SELECT
        order_id,
        COUNT(*)::int AS line_count,
        SUM(quantity)::int AS total_quantity
    FROM {{ ref('stg_order_items') }}
    GROUP BY order_id
)
SELECT
    o.id,
    o.order_number,
    o.relation_id,
    TO_CHAR(o.ordered_at::date, 'YYYYMMDD')::int AS order_date_id,
    TO_CHAR(o.shipped_at::date, 'YYYYMMDD')::int AS shipped_date_id,
    TO_CHAR(o.delivered_at::date, 'YYYYMMDD')::int AS delivered_date_id,
    o.order_status,
    o.currency_code,
    COALESCE(ir.line_count, 0) AS line_count,
    COALESCE(ir.total_quantity, 0) AS total_quantity,
    o.subtotal_amount,
    o.discount_amount,
    o.tax_amount,
    o.shipping_amount,
    o.total_amount,
    o.ordered_at,
    o.shipped_at,
    o.delivered_at,
    o.created_at,
    o.updated_at
FROM {{ ref('stg_orders') }} AS o
LEFT JOIN item_rollup AS ir
    ON ir.order_id = o.id
