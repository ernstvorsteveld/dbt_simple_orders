SELECT
    order_item_id AS id,
    order_id,
    line_number,
    sku,
    product_name,
    product_category,
    quantity,
    unit_price,
    discount_pct,
    tax_rate_pct,
    line_subtotal,
    line_discount,
    line_tax,
    line_total,
    created_at
FROM {{ source('raw', 'order_items') }}
