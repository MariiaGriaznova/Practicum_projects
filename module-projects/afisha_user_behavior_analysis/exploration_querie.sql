-- View the first rows of tables

SELECT * FROM afisha.purchases LIMIT 10;
SELECT * FROM afisha.events LIMIT 10;
SELECT * FROM afisha.venues LIMIT 10;
SELECT * FROM afisha.city LIMIT 10;
SELECT * FROM afisha.regions LIMIT 10;

-- Checking the uniqueness of keys

SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS unique_order_ids FROM afisha.purchases;
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT event_id) AS unique_event_ids FROM afisha.events;
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT venue_id) AS unique_venue_ids FROM afisha.venues;
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT city_id) AS unique_city_ids FROM afisha.city;
SELECT COUNT(*) AS total_rows, COUNT(DISTINCT region_id) AS unique_region_ids FROM afisha.regions;

-- Checking gaps

SELECT 
    SUM(CASE WHEN device_type_canonical IS NULL THEN 1 ELSE 0 END) AS missing_device_type,
    SUM(CASE WHEN revenue IS NULL THEN 1 ELSE 0 END) AS missing_revenue,
    SUM(CASE WHEN created_dt_msk IS NULL THEN 1 ELSE 0 END) AS missing_created_dt,
    SUM(CASE WHEN event_id IS NULL THEN 1 ELSE 0 END) AS missing_event_id
FROM afisha.purchases;

SELECT 
    SUM(CASE WHEN event_type_description IS NULL THEN 1 ELSE 0 END) AS missing_event_type_description,
    SUM(CASE WHEN event_type_main IS NULL THEN 1 ELSE 0 END) AS missing_event_type_main,
    SUM(CASE WHEN venue_id IS NULL THEN 1 ELSE 0 END) AS missing_venue_id,
    SUM(CASE WHEN city_id IS NULL THEN 1 ELSE 0 END) AS missing_city_id
FROM afisha.events;

-- Distribution of categories

SELECT device_type_canonical, COUNT(*) AS orders_count
FROM afisha.purchases
GROUP BY device_type_canonical
ORDER BY orders_count DESC;

SELECT event_type_main, COUNT(*) AS events_count
FROM afisha.events
GROUP BY event_type_main
ORDER BY events_count DESC;

SELECT currency_code, COUNT(*) AS orders_count
FROM afisha.purchases
GROUP BY currency_code
ORDER BY orders_count DESC;

-- Data period

SELECT MIN(created_dt_msk) AS min_date, MAX(created_dt_msk) AS max_date
FROM afisha.purchases;

-- Key service indicators for the entire period

SELECT 
    currency_code,
    SUM(revenue) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders,
    AVG(revenue) AS avg_revenue_per_order,
    COUNT(DISTINCT user_id) AS total_users
FROM 
    afisha.purchases
GROUP BY 
    currency_code
ORDER BY 
    total_revenue DESC;

-- Distribution of revenue and number of orders in rubles by device type

WITH set_config_precode AS (
  SELECT set_config('synchronize_seqscans', 'off', true)
)
SELECT 
    device_type_canonical,
    SUM(revenue) AS total_revenue,
    COUNT(order_id) AS total_orders,
    AVG(revenue) AS avg_revenue_per_order,
    ROUND(SUM(revenue)::numeric / (SELECT SUM(revenue)::numeric 
                          FROM afisha.purchases 
                          WHERE currency_code = 'rub'), 3) AS revenue_share
FROM 
    afisha.purchases
WHERE 
    currency_code = 'rub'
GROUP BY 
    device_type_canonical
ORDER BY 
    revenue_share DESC;

-- Distribution of the number of orders and their revenue in rubles
-- depending on the type of event

SELECT 
    e.event_type_main,
    SUM(p.revenue) AS total_revenue,
    COUNT(p.order_id) AS total_orders,
    AVG(p.revenue) AS avg_revenue_per_order,
    COUNT(DISTINCT e.event_name_code) AS total_event_name,
    SUM(p.tickets_count * 1.0) / COUNT(DISTINCT p.order_id) AS avg_tickets,
    SUM(p.revenue) / NULLIF(SUM(p.tickets_count), 0) AS avg_ticket_revenue,
    ROUND(SUM(p.revenue)::numeric / (SELECT SUM(revenue)::numeric FROM afisha.purchases WHERE currency_code = 'rub'), 3) AS revenue_share
FROM 
    afisha.purchases p
JOIN 
    afisha.events e ON p.event_id = e.event_id
WHERE 
    p.currency_code = 'rub'
GROUP BY 
    e.event_type_main
ORDER BY 
    total_orders DESC;

-- Change in revenue, number of orders, unique customers and average cost 
-- of one order in weekly dynamics (in rubles)

SELECT 
    CAST(DATE_TRUNC('week', created_dt_msk) AS date) AS week,
    SUM(revenue) AS total_revenue,
    COUNT(order_id) AS total_orders,
    COUNT(DISTINCT user_id) AS total_users,
    SUM(revenue) / COUNT(DISTINCT order_id) AS revenue_per_order
FROM 
    afisha.purchases
WHERE 
    currency_code = 'rub'
GROUP BY 
    week
ORDER BY 
    week ASC;

-- Top 7 regions by total revenue, including only orders in rubles

SELECT
    r.region_name,
    SUM(p.revenue) AS total_revenue,
    COUNT(p.order_id) AS total_orders,
    COUNT(DISTINCT p.user_id) AS total_users,
    SUM(p.tickets_count * 1) AS total_tickets,
    SUM(p.revenue) / SUM(p.tickets_count) AS one_ticket_cost
FROM
    afisha.purchases p
JOIN 
    afisha.events e ON p.event_id = e.event_id
JOIN 
    afisha.city c ON e.city_id = c.city_id
JOIN 
    afisha.regions r ON c.region_id = r.region_id
WHERE
    p.currency_code = 'rub'
GROUP BY
    r.region_name
ORDER BY
    total_revenue DESC
LIMIT 7;