/* Project "Secrets of Darkwood"
 * Project Goal: to study the influence of player characteristics and character races
 * on the purchase of the in-game currency "paradise petals," and to assess
 * player activity during in-game purchases
 * 
 * Author: Maria Gryaznova
 * Date: October 21, 2024
*/

-- Part 1. Exploratory Data Analysis
-- Task 1. Analyzing the share of paying players

-- 1.1. Share of paying users across all data:
WITH total_users AS (
    SELECT COUNT(id) AS total_users
    FROM fantasy.users 				 
),	-- CTE to calculate the total number of players
paying_users AS (
    SELECT COUNT(id) AS paying_users
    FROM fantasy.users
    WHERE payer = 1
)	-- CTE to calculate the number of paying players
SELECT 
    total_users,
    paying_users,
    ROUND(paying_users::numeric / total_users::numeric, 2) AS paying_users_rate  -- Calculate the share of paying players
FROM total_users
CROSS JOIN paying_users;    -- Combine CTEs

-- 1.2. Share of paying users by character race:
WITH total_users_race AS (
	SELECT COUNT(id) AS total_users,
		   race
	FROM fantasy.users AS u
	LEFT JOIN fantasy.race AS r ON u.race_id = r.race_id
	GROUP BY race
),	-- CTE to calculate the total number of players by race
paying_users_race AS (
	SELECT COUNT(id) AS paying_users,
		   race
	FROM fantasy.users AS u
	LEFT JOIN fantasy.race AS r ON u.race_id = r.race_id
	WHERE payer = 1
	GROUP BY race
)	-- CTE to calculate the number of paying players by race
SELECT race,
	   paying_users,
	   total_users,
	   ROUND(paying_users::numeric / total_users::numeric, 2) AS paying_users_race_rate  -- Calculate the share of paying players by race
FROM total_users_race AS tu
LEFT JOIN paying_users_race AS pu USING(race)
ORDER BY paying_users_race_rate DESC;	-- Sort by the share of paying players

-- Task 2. In-game purchases analysis

-- 2.1. Statistical indicators for the "amount" field:
SELECT 
    COUNT(transaction_id) AS total_buy,            -- Total number of purchases
    SUM(amount) AS total_amount,                   -- Total purchase amount
    MIN(amount) AS min_amount,                     -- Minimum purchase amount
    MAX(amount) AS max_amount,                     -- Maximum purchase amount
    ROUND(AVG(amount)::numeric, 2) AS avg_amount,  -- Average purchase amount
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY amount)::numeric, 2) AS median_amount, -- Median purchase amount
    ROUND(STDDEV(amount)::numeric, 2) AS stdev_amount -- Standard deviation of purchase amounts
FROM fantasy.events;

-- 2.2: Anomalous zero-amount purchases:
WITH total_amount AS (
    SELECT COUNT(*) AS total_amount
    FROM fantasy.events			-- Calculate the total number of purchases
),
null_amount AS (
    SELECT COUNT(amount) AS null_amount   
    FROM fantasy.events
    WHERE amount = 0
)		-- Count the number of transactions where the amount is zero
SELECT null_amount,
       ROUND(null_amount::numeric / total_amount::numeric, 4) AS null_amount_rate	-- Calculate the share of zero-amount transactions
FROM total_amount
CROSS JOIN null_amount;  -- Combine results from CTEs

-- 2.3: Comparative analysis of paying and non-paying players' activity:
WITH user_aggregates AS (
    SELECT 
        u.id,
        u.payer,
        COUNT(e.transaction_id) AS total_transactions,  -- Count transactions per user
        SUM(e.amount) AS total_amount  -- Sum of purchases per user
    FROM fantasy.users u
    INNER JOIN fantasy.events e ON u.id = e.id
    WHERE e.amount > 0  -- Exclude zero-amount purchases
    GROUP BY u.id, u.payer
)
SELECT 
    CASE 
        WHEN payer = 1 THEN 'Paying'
        WHEN payer = 0 THEN 'Non-paying'
    END AS pay_status,
    COUNT(id) AS user_count,  -- Number of users in each group
    ROUND(AVG(total_transactions)::numeric, 2) AS avg_trans_per_user,  -- Average number of transactions per user
    ROUND(AVG(total_amount)::numeric, 2) AS avg_amount_per_user  -- Average total purchase amount per user
FROM user_aggregates
GROUP BY payer;

-- 2.4: Popular epic items:
WITH total_users AS (
	SELECT COUNT(id) AS total_users
	FROM fantasy.users
),	-- Calculate the total number of users
total_transactions AS (
	SELECT COUNT(transaction_id) AS total_transactions
	FROM fantasy.events
	WHERE amount > 0
),	-- Calculate the total number of non-zero transactions
items AS (
	SELECT 
        game_items, 
        COUNT(transaction_id) AS total_sale,
        COUNT(DISTINCT id) AS users
    FROM fantasy.events
    INNER JOIN fantasy.items USING(item_code)
    WHERE amount > 0
    GROUP BY game_items
)	-- Count the sales of each item and the number of users who purchased them
SELECT 
	game_items,
	total_sale,
	ROUND(total_sale::numeric / total_transactions::numeric, 4) AS total_sale_rate,	-- Sale share of each item relative to total transactions
	ROUND(users::numeric / total_users::numeric, 4) AS users_rate	-- Share of users who bought the item
FROM items
CROSS JOIN total_users
CROSS JOIN total_transactions	-- Combine CTEs
ORDER BY users_rate DESC;	-- Sort by item popularity among players

-- Part 2. Solving ad hoc tasks
-- Task 1. Dependence of player activity on character race:
WITH total_users_race AS (
    SELECT COUNT(id) AS total_users,
           race
    FROM fantasy.users
    LEFT JOIN fantasy.race USING(race_id)
    GROUP BY race
),  -- Total number of registered players by race
count_users_buy AS (
    SELECT 
        COUNT(DISTINCT id) AS count_users_buy,
        race,
        SUM(amount) AS total_purchase_amount,  -- Total purchase amount by race
        COUNT(transaction_id) AS total_transactions  -- Total number of transactions
    FROM fantasy.events
    LEFT JOIN fantasy.users USING(id)
    LEFT JOIN fantasy.race USING(race_id)
    WHERE amount > 0
    GROUP BY race
),  -- Number of players who made purchases and total purchases by race
paying_users_race AS (
    SELECT COUNT(id) AS paying_users,
           race
    FROM fantasy.users
    LEFT JOIN fantasy.race USING(race_id)
    WHERE payer = 1
    GROUP BY race
),  -- Number of paying players by race
avg_purchase_per_user AS (
    SELECT 
        race,
        ROUND(SUM(amount)::numeric / COUNT(DISTINCT id), 2) AS avg_purchase_amount_per_user,  -- Average purchase amount per player
        ROUND(COUNT(transaction_id)::numeric / COUNT(DISTINCT id), 2) AS avg_transactions_per_user  -- Average number of transactions per player
    FROM fantasy.events
    LEFT JOIN fantasy.users USING(id)
    LEFT JOIN fantasy.race USING(race_id)
    WHERE amount > 0
    GROUP BY race
)  -- Average purchase amount and number of transactions per player by race
SELECT 
    t.race,
    t.total_users,
    c.count_users_buy,
    ROUND(c.count_users_buy::numeric / t.total_users::numeric, 2) AS buy_users_rate,  -- Share of players who made purchases
    ROUND(p.paying_users::numeric / c.count_users_buy::numeric, 2) AS paying_users_rate,  -- Share of paying players among purchasers
    a.avg_transactions_per_user,  -- Average number of transactions per player
    a.avg_purchase_amount_per_user,  -- Average purchase amount per player
    ROUND(a.avg_purchase_amount_per_user / a.avg_transactions_per_user, 2) AS avg_amount_per_transaction  -- Average amount per transaction
FROM total_users_race t
LEFT JOIN count_users_buy c ON t.race = c.race
LEFT JOIN avg_purchase_per_user a ON t.race = a.race
LEFT JOIN paying_users_race p ON t.race = p.race
ORDER BY t.race;