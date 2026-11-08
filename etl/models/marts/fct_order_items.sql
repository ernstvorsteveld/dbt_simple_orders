SELECT
    oi.id,
    oi.order_id,
    o.relation_id,
    p.id AS product_id,
    TO_CHAR(o.ordered_at::date, 'YYYYMMDD')::int AS order_date_id,
    o.order_number,
    oi.line_number,
    o.order_status,
    o.currency_code,
    oi.quantity,
    oi.unit_price,
    oi.discount_pct,
    oi.tax_rate_pct,
    oi.line_subtotal,
    oi.line_discount,
    oi.line_tax,
    oi.line_total,
    o.ordered_at,
    oi.created_at
FROM {{ ref('stg_order_items') }} AS oi
INNER JOIN {{ ref('stg_orders') }} AS o
    ON o.id = oi.order_id
INNER JOIN {{ ref('dim_products') }} AS p
    ON p.sku = oi.sku
