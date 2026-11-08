WITH distinct_products AS (
    SELECT DISTINCT ON (sku)
        sku,
        product_name,
        product_category,
        unit_price
    FROM {{ ref('stg_order_items') }}
    ORDER BY sku, created_at DESC, id DESC
)
SELECT
    ROW_NUMBER() OVER (ORDER BY sku)::bigint AS id,
    sku,
    product_name,
    product_category,
    unit_price
FROM distinct_products
