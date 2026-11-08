WITH params AS (
    SELECT
        ARRAY[
            'Emma', 'Noah', 'Sophie', 'Lucas', 'Julia', 'Daan', 'Mila', 'Sem',
            'Anna', 'Liam', 'Eva', 'Finn', 'Tess', 'Bram', 'Sara', 'Milan'
        ] AS first_names,
        ARRAY[
            'de Jong', 'Jansen', 'de Vries', 'van den Berg', 'van Dijk', 'Bakker',
            'Janssen', 'Visser', 'Smit', 'Meijer', 'Peeters', 'Mulder',
            'de Boer', 'Bos', 'Vos', 'Peters'
        ] AS last_names,
        ARRAY[
            'Northstar', 'Delta', 'Horizon', 'Lowlands', 'Apex', 'Veritas',
            'Cobalt', 'Meridian', 'Vanguard', 'Rhine', 'Atlas', 'Kanaal'
        ] AS company_prefixes,
        ARRAY[
            'Logistics B.V.', 'Solutions B.V.', 'Trading Group', 'Technologies',
            'Consulting', 'Analytics B.V.', 'Systems', 'Partners'
        ] AS company_suffixes,
        ARRAY[
            'Keizersgracht', 'Stationsplein', 'Kerkstraat', 'Hoofdstraat',
            'Nieuweweg', 'Marktstraat', 'Wilhelminalaan', 'Parklaan',
            'Industrieweg', 'Havenstraat', 'Molenweg', 'Dorpsstraat'
        ] AS streets
),
locations AS (
    SELECT *
    FROM (VALUES
        (1,  'Amsterdam', '1012 AB',  'NL', '+31 20 ', 'NL'),
        (2,  'Rotterdam', '3011 AA',  'NL', '+31 10 ', 'NL'),
        (3,  'Utrecht',   '3511 LX',  'NL', '+31 30 ', 'NL'),
        (4,  'Eindhoven', '5611 EM',  'NL', '+31 40 ', 'NL'),
        (5,  'Antwerp',   '2000',     'BE', '+32 3 ',  'BE'),
        (6,  'Brussels',  '1000',     'BE', '+32 2 ',  'BE'),
        (7,  'Berlin',    '10115',    'DE', '+49 30 ', 'DE'),
        (8,  'Munich',    '80331',    'DE', '+49 89 ', 'DE'),
        (9,  'Paris',     '75002',    'FR', '+33 1 ',  'FR'),
        (10, 'London',    'EC2A 4NE', 'GB', '+44 20 ', 'GB'),
        (11, 'New York',  '10001',    'US', '+1 212 ', 'US'),
        (12, 'Austin',    '78701',    'US', '+1 512 ', 'US')
    ) AS t(loc_id, city, postal_code, country_code, phone_prefix, vat_prefix)
),
generated AS (
    SELECT
        g,
        (g % 3 = 0) AS is_org,
        p.first_names[1 + ((g * 3) % array_length(p.first_names, 1))] AS fname,
        p.last_names[1 + ((g * 5) % array_length(p.last_names, 1))] AS lname,
        p.company_prefixes[1 + ((g * 7) % array_length(p.company_prefixes, 1))] AS comp_prefix,
        p.company_prefixes[1 + ((g * 7) % array_length(p.company_prefixes, 1))]
            || ' '
            || p.company_suffixes[1 + ((g * 11) % array_length(p.company_suffixes, 1))] AS comp_name,
        p.streets[1 + ((g * 13) % array_length(p.streets, 1))] AS street_name,
        loc.city,
        loc.postal_code,
        loc.country_code,
        loc.phone_prefix,
        loc.vat_prefix,
        TIMESTAMPTZ '2025-01-01 08:00:00+00'
            + ((g * 19) % 630) * INTERVAL '1 day'
            + ((g * 37) % 86400) * INTERVAL '1 second' AS created_ts
    FROM generate_series(1, 500) AS g
    CROSS JOIN params AS p
    INNER JOIN locations AS loc
        ON loc.loc_id = 1 + ((g * 7) % 12)
)
INSERT INTO raw.relations (
    external_ref,
    relation_type,
    relation_role,
    display_name,
    first_name,
    last_name,
    company_name,
    tax_id,
    email,
    phone,
    street_address,
    postal_code,
    city,
    country_code,
    status,
    created_at,
    updated_at
)
SELECT
    'REL-' || LPAD(g::text, 6, '0') AS external_ref,
    CASE WHEN is_org THEN 'organization' ELSE 'person' END AS relation_type,
    CASE
        WHEN g % 10 IN (0, 1, 2, 3, 4, 5) THEN 'customer'
        WHEN g % 10 IN (6, 7)             THEN 'prospect'
        WHEN g % 10 = 8                   THEN 'supplier'
        ELSE                                   'partner'
    END AS relation_role,
    CASE WHEN is_org THEN comp_name ELSE fname || ' ' || lname END AS display_name,
    CASE WHEN is_org THEN NULL ELSE fname END AS first_name,
    CASE WHEN is_org THEN NULL ELSE lname END AS last_name,
    CASE
        WHEN is_org     THEN comp_name
        WHEN g % 4 = 0  THEN comp_name
        ELSE                 NULL
    END AS company_name,
    CASE
        WHEN is_org THEN vat_prefix || LPAD(((100000000 + g * 13791) % 999999999)::text, 9, '0')
        ELSE             NULL
    END AS tax_id,
    CASE
        WHEN g % 25 = 0 THEN NULL
        WHEN is_org     THEN 'info@' || lower(comp_prefix) || '-' || g::text || '.example.com'
        ELSE                 lower(fname || '.' || replace(lname, ' ', '') || g::text || '@example.com')
    END AS email,
    CASE
        WHEN g % 18 = 0 THEN NULL
        ELSE                 phone_prefix || LPAD(((1000000 + g * 8191) % 9999999)::text, 7, '0')
    END AS phone,
    street_name || ' ' || (1 + ((g * 11) % 240))::text AS street_address,
    postal_code,
    city,
    country_code,
    CASE
        WHEN g % 20 = 0 THEN 'blocked'
        WHEN g % 7  = 0 THEN 'inactive'
        ELSE                 'active'
    END AS status,
    created_ts AS created_at,
    CASE
        WHEN g % 3 = 0 THEN created_ts
        ELSE                created_ts
                            + ((g * 13) % 30) * INTERVAL '1 day'
                            + ((g * 29) % 3600) * INTERVAL '1 second'
    END AS updated_at
FROM generated
ON CONFLICT (external_ref) DO NOTHING;
