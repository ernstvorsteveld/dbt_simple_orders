-- 1. Generate 2 to 8 orders for each 'customer' and 'partner' relation
WITH eligible_relations AS (
    SELECT
        r.relation_id,
        r.country_code,
        r.created_at,
        2 + ((r.relation_id * 7) % 7)::int AS num_orders
    FROM raw.relations AS r
    WHERE r.relation_role IN ('customer', 'partner')
),
order_candidates AS (
    SELECT
        er.relation_id,
        er.country_code,
        ord_seq,
        ROW_NUMBER() OVER (ORDER BY er.relation_id, ord_seq) AS global_seq,
        er.created_at + (
            (TIMESTAMPTZ '2026-10-25 18:00:00+00' - er.created_at)
            * ((ord_seq::double precision - 0.5) / er.num_orders::double precision)
        ) AS ordered_ts
    FROM eligible_relations AS er
    CROSS JOIN LATERAL generate_series(1, er.num_orders) AS ord_seq
),
order_staged AS (
    SELECT
        'ORD-' || EXTRACT(YEAR FROM ordered_ts)::int::text
            || '-' || LPAD(global_seq::text, 6, '0') AS order_number,
        relation_id,
        CASE
            WHEN ordered_ts >= TIMESTAMPTZ '2026-10-10 00:00:00+00' THEN
                CASE (global_seq % 5)
                    WHEN 0 THEN 'draft'
                    WHEN 1 THEN 'confirmed'
                    WHEN 2 THEN 'shipped'
                    WHEN 3 THEN 'delivered'
                    ELSE        'cancelled'
                END
            ELSE
                CASE
                    WHEN global_seq % 12 = 0 THEN 'cancelled'
                    WHEN global_seq % 15 = 0 THEN 'returned'
                    ELSE                          'delivered'
                END
        END AS order_status,
        CASE country_code
            WHEN 'GB' THEN 'GBP'
            WHEN 'US' THEN 'USD'
            ELSE           'EUR'
        END AS currency_code,
        ordered_ts,
        global_seq
    FROM order_candidates
)
INSERT INTO raw.orders (
    order_number,
    relation_id,
    order_status,
    currency_code,
    ordered_at,
    shipped_at,
    delivered_at,
    created_at,
    updated_at
)
SELECT
    order_number,
    relation_id,
    order_status,
    currency_code,
    ordered_ts AS ordered_at,
    CASE
        WHEN order_status IN ('shipped', 'delivered', 'returned') THEN
            ordered_ts
            + (1 + (global_seq % 3)) * INTERVAL '1 day'
            + ((global_seq * 43) % 28800) * INTERVAL '1 second'
        ELSE NULL
    END AS shipped_at,
    CASE
        WHEN order_status IN ('delivered', 'returned') THEN
            ordered_ts
            + (4 + (global_seq % 4)) * INTERVAL '1 day'
            + ((global_seq * 61) % 28800) * INTERVAL '1 second'
        ELSE NULL
    END AS delivered_at,
    ordered_ts AS created_at,
    CASE
        WHEN order_status IN ('delivered', 'returned') THEN
            ordered_ts
            + (4 + (global_seq % 4)) * INTERVAL '1 day'
            + ((global_seq * 61) % 28800) * INTERVAL '1 second'
        WHEN order_status = 'shipped' THEN
            ordered_ts
            + (1 + (global_seq % 3)) * INTERVAL '1 day'
            + ((global_seq * 43) % 28800) * INTERVAL '1 second'
        WHEN order_status = 'cancelled' THEN
            ordered_ts + INTERVAL '4 hours'
        ELSE
            ordered_ts
    END AS updated_at
FROM order_staged
ON CONFLICT (order_number) DO NOTHING;

-- 2. Generate 1 to 5 distinct product line items per order
WITH products AS (
    SELECT *
    FROM (VALUES
        (1,  'SKU-HW-101', 'ProBook Laptop 14"',          'Hardware',    1199.00::numeric(12,2)),
        (2,  'SKU-HW-102', 'UltraWide Monitor 34"',       'Hardware',     549.00::numeric(12,2)),
        (3,  'SKU-HW-103', 'USB-C Docking Station',       'Accessories',  189.00::numeric(12,2)),
        (4,  'SKU-HW-104', 'Ergonomic Mechanical Keyboard','Accessories', 129.00::numeric(12,2)),
        (5,  'SKU-HW-105', 'Wireless Precision Mouse',    'Accessories',   79.00::numeric(12,2)),
        (6,  'SKU-HW-106', 'Noise-Cancelling Headset',    'Audio',        249.00::numeric(12,2)),
        (7,  'SKU-HW-107', '4K Conference Webcam',        'Audio',        159.00::numeric(12,2)),
        (8,  'SKU-NW-201', 'Managed Gigabit Switch 24p',  'Networking',   399.00::numeric(12,2)),
        (9,  'SKU-NW-202', 'Wi-Fi 7 Access Point',        'Networking',   279.00::numeric(12,2)),
        (10, 'SKU-NW-203', 'Security Gateway Appliance',  'Networking',   649.00::numeric(12,2)),
        (11, 'SKU-ST-301', 'NVMe SSD 2TB',                'Storage',      169.00::numeric(12,2)),
        (12, 'SKU-ST-302', 'NAS Enclosure 4-Bay',         'Storage',      599.00::numeric(12,2)),
        (13, 'SKU-SW-401', 'Cloud Backup License (1 yr)', 'Software',      99.00::numeric(12,2)),
        (14, 'SKU-SW-402', 'Endpoint Security Suite',     'Software',     149.00::numeric(12,2)),
        (15, 'SKU-SV-501', 'Next-Business-Day Warranty',  'Services',     119.00::numeric(12,2)),
        (16, 'SKU-SV-502', 'Remote Onboarding Package',   'Services',     350.00::numeric(12,2))
    ) AS t(prod_idx, sku, product_name, product_category, unit_price)
),
base_lines AS (
    SELECT
        o.order_id,
        o.ordered_at,
        line_num AS line_number,
        p.sku,
        p.product_name,
        p.product_category,
        p.unit_price,
        CASE
            WHEN r.relation_type = 'organization'
                THEN 1 + ((o.order_id * 3 + line_num * 5) % 8)::int
            ELSE
                1 + ((o.order_id + line_num * 3) % 3)::int
        END AS quantity,
        CASE
            WHEN (o.order_id + line_num) % 10 = 0 THEN 15.00
            WHEN (o.order_id + line_num) % 6  = 0 THEN 10.00
            WHEN (o.order_id + line_num) % 4  = 0 THEN 5.00
            ELSE                                       0.00
        END::numeric(5, 2) AS discount_pct,
        CASE r.country_code
            WHEN 'NL' THEN 21.00
            WHEN 'BE' THEN 21.00
            WHEN 'DE' THEN 19.00
            WHEN 'FR' THEN 20.00
            WHEN 'GB' THEN 20.00
            WHEN 'US' THEN 8.25
            ELSE           21.00
        END::numeric(5, 2) AS tax_rate_pct
    FROM raw.orders AS o
    INNER JOIN raw.relations AS r
        ON r.relation_id = o.relation_id
    CROSS JOIN LATERAL generate_series(1, 1 + ((o.order_id * 5) % 5)::int) AS line_num
    INNER JOIN products AS p
        ON p.prod_idx = 1 + (((o.order_id * 7) + (line_num * 3)) % 16)::int
),
calculated_lines AS (
    SELECT
        order_id,
        ordered_at,
        line_number,
        sku,
        product_name,
        product_category,
        quantity,
        unit_price,
        discount_pct,
        tax_rate_pct,
        (quantity * unit_price)::numeric(12, 2) AS line_subtotal,
        ROUND((quantity * unit_price) * discount_pct / 100.0, 2)::numeric(12, 2) AS line_discount
    FROM base_lines
)
INSERT INTO raw.order_items (
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
)
SELECT
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
    ROUND((line_subtotal - line_discount) * tax_rate_pct / 100.0, 2)::numeric(12, 2) AS line_tax,
    (
        (line_subtotal - line_discount)
        + ROUND((line_subtotal - line_discount) * tax_rate_pct / 100.0, 2)
    )::numeric(12, 2) AS line_total,
    ordered_at AS created_at
FROM calculated_lines
ON CONFLICT (order_id, line_number) DO NOTHING;

-- 3. Roll up exact line item totals onto raw.orders headers
WITH order_rollups AS (
    SELECT
        oi.order_id,
        SUM(oi.line_subtotal)::numeric(12, 2) AS subtotal_amount,
        SUM(oi.line_discount)::numeric(12, 2) AS discount_amount,
        SUM(oi.line_tax)::numeric(12, 2)      AS tax_amount
    FROM raw.order_items AS oi
    GROUP BY oi.order_id
)
UPDATE raw.orders AS o
SET
    subtotal_amount = r.subtotal_amount,
    discount_amount = r.discount_amount,
    tax_amount      = r.tax_amount,
    shipping_amount = CASE
        WHEN (r.subtotal_amount - r.discount_amount) >= 500.00 THEN 0.00
        ELSE 12.50
    END,
    total_amount    = (r.subtotal_amount - r.discount_amount)
                      + r.tax_amount
                      + CASE
                            WHEN (r.subtotal_amount - r.discount_amount) >= 500.00 THEN 0.00
                            ELSE 12.50
                        END
FROM order_rollups AS r
WHERE o.order_id = r.order_id;
