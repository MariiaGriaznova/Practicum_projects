-- Viewing the first rows of the users table
SELECT *
FROM telecom.users
LIMIT 20;

-- Searching for missing values in the users table
SELECT *
FROM telecom.users
WHERE age IS NULL 
   OR churn_date IS NULL 
   OR city IS NULL 
   OR first_name IS NULL 
   OR last_name IS NULL 
   OR reg_date IS NULL 
   OR tariff IS NULL
LIMIT 10;

-- Share of active customers
SELECT 1 - CAST(COUNT(churn_date) AS real) / COUNT(*)
FROM telecom.users;

-- Checking for users with multiple tariffs (data quality check)
SELECT user_id,
       COUNT(tariff)
FROM telecom.users
WHERE churn_date IS NULL
GROUP BY user_id
HAVING COUNT(tariff) > 1;

-- Checking for missing values in the calls table
SELECT *
FROM telecom.calls
WHERE duration IS NULL 
   OR call_date IS NULL;

-- Minimum and maximum call durations
SELECT MIN(duration) AS min_duration,
       MAX(duration) AS max_duration
FROM telecom.calls;

-- Share of calls with zero duration
SELECT COUNT(duration)::real / (SELECT COUNT(id) FROM telecom.calls)
FROM telecom.calls
WHERE duration = 0;

-- Longest daily calls
SELECT user_id,
       call_date,
       SUM(duration)/60 AS total_day_duration
FROM telecom.calls
GROUP BY user_id, call_date
ORDER BY total_day_duration DESC
LIMIT 10;

-- ===============================
-- Main Analytical Query:
-- Calculating customer activity per month and computing costs
-- ===============================

WITH 
-- Total monthly call duration
monthly_duration AS (
    SELECT user_id,
           DATE_TRUNC('month', call_date::timestamp)::date AS dt_month,    
           CEIL(SUM(duration)) AS month_duration
    FROM telecom.calls
    GROUP BY user_id, dt_month
),

-- Total monthly internet traffic
monthly_internet AS (
    SELECT user_id,
           DATE_TRUNC('month', session_date::timestamp)::date AS dt_month,  
           SUM(mb_used) AS month_mb_traffic
    FROM telecom.internet
    GROUP BY user_id, dt_month
),

-- Total number of SMS per month
monthly_sms AS (
    SELECT user_id,
           DATE_TRUNC('month', message_date::timestamp)::date AS dt_month,  
           COUNT(message_date) AS month_sms
    FROM telecom.messages
    GROUP BY user_id, dt_month
),

-- Unique pairs of user_id and activity month
user_activity_months AS (
    SELECT user_id, dt_month FROM monthly_duration
    UNION
    SELECT user_id, dt_month FROM monthly_internet   
    UNION
    SELECT user_id, dt_month FROM monthly_sms
),

-- Combining customer activity data per month
users_stat AS (
    SELECT u.user_id,
           u.dt_month,
           month_duration,
           month_mb_traffic,
           month_sms
    FROM user_activity_months AS u
    LEFT JOIN monthly_duration AS md ON u.user_id = md.user_id AND u.dt_month = md.dt_month
    LEFT JOIN monthly_internet AS mi ON u.user_id = mi.user_id AND u.dt_month = mi.dt_month
    LEFT JOIN monthly_sms AS mm ON u.user_id = mm.user_id AND u.dt_month = mm.dt_month
),

-- Identifying over-limit usage by customers
user_over_limits AS (
    SELECT us.user_id,
           us.dt_month,
           u.tariff,
           us.month_duration,
           us.month_mb_traffic,
           us.month_sms,
           CASE WHEN us.month_duration >= t.minutes_included THEN (us.month_duration - t.minutes_included) ELSE 0 END AS duration_over,
           CASE WHEN us.month_mb_traffic >= t.mb_per_month_included THEN (us.month_mb_traffic - t.mb_per_month_included) / 1024::real ELSE 0 END AS gb_traffic_over,
           CASE WHEN us.month_sms >= t.messages_included THEN (us.month_sms - t.messages_included) ELSE 0 END AS sms_over
    FROM users_stat AS us
    LEFT JOIN (SELECT tariff, user_id FROM telecom.users) AS u ON us.user_id = u.user_id
    LEFT JOIN telecom.tariffs AS t ON u.tariff = t.tariff_name
),

-- Calculating customers' monthly costs
users_costs AS (
    SELECT uol.user_id,
           uol.dt_month,
           uol.tariff,
           uol.month_duration,
           uol.month_mb_traffic,
           uol.month_sms,
           t.rub_monthly_fee, 
           t.rub_monthly_fee 
           + uol.duration_over * t.rub_per_minute
           + uol.gb_traffic_over * t.rub_per_gb
           + uol.sms_over * t.rub_per_message AS total_cost
    FROM user_over_limits AS uol
    LEFT JOIN telecom.tariffs AS t ON uol.tariff = t.tariff_name
)

-- Final aggregation:
SELECT tariff,
       COUNT(DISTINCT user_id) AS total_users,
       ROUND(AVG(total_cost)::numeric, 2) AS avg_total_cost,
       ROUND((AVG(total_cost)::numeric - rub_monthly_fee::numeric), 2) AS overcost
FROM users_costs
WHERE user_id IN (
    SELECT user_id
    FROM telecom.users
    WHERE churn_date IS NULL
)
AND total_cost > rub_monthly_fee
GROUP BY tariff, rub_monthly_fee;
