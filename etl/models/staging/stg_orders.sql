SELECT
    order_id AS id,
    order_number,
    relation_id,
    order_status,
    currency_code,
    subtotal_amount,
    discount_amount,
    tax_amount,
    shipping_amount,
    total_amount,
    ordered_at,
    shipped_at,
    delivered_at,
    created_at,
    updated_at
FROM {{ source('raw', 'orders') }}
