/* First module project: real estate agency data analysis
 * Part 2. Solving ad hoc tasks
 * 
 * Author: Mariya Gryaznova
 * Date: 
*/

-- Example of filtering out anomalous values
-- Identify outliers based on percentile values:
WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),
-- Find IDs of listings that do not contain outliers:
filtered_id AS(
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits) 
        AND rooms < (SELECT rooms_limit FROM limits) 
        AND balcony < (SELECT balcony_limit FROM limits) 
        AND ceiling_height < (SELECT ceiling_height_limit_h FROM limits) 
        AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)
    )
-- Display listings without outliers:
SELECT *
FROM real_estate.flats
WHERE id IN (SELECT * FROM filtered_id);


-- Task 1: Listing activity time
-- The query should answer these questions:
-- 1. Which real estate market segments in Saint Petersburg and Leningrad Region cities 
--    have the shortest or longest listing activity times?
-- 2. Which property characteristics, including area, average price per square meter, 
--    number of rooms and balconies, and others, influence the listing activity time? 
--    How do these dependencies vary between regions?
-- 3. Are there differences between properties in Saint Petersburg and the Leningrad Region?

WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),		-- These limits will be used to filter out outlier properties
filtered_id AS (
    SELECT id
    FROM real_estate.flats  
    WHERE 
        total_area < (SELECT total_area_limit FROM limits) 
        AND rooms < (SELECT rooms_limit FROM limits) 
        AND balcony < (SELECT balcony_limit FROM limits) 
        AND ceiling_height < (SELECT ceiling_height_limit_h FROM limits) 
        AND ceiling_height > (SELECT ceiling_height_limit_l FROM limits)
),		-- Select properties whose characteristics are within the set limits
categorized AS (
    SELECT 
        CASE WHEN c.city = 'Санкт-Петербург' THEN 'Saint Petersburg' 
        	 ELSE 'Leningrad Region' 
        END AS region,		-- Determine the region
        CASE 				-- Define listing activity periods
            WHEN a.days_exposition IS NULL THEN 'no category'		-- Assign a "no category" for listings without activity duration
	        WHEN a.days_exposition <= 30 THEN 'up to a month'
            WHEN a.days_exposition <= 90 THEN 'up to three months'
            WHEN a.days_exposition <= 180 THEN 'up to six months'
            ELSE 'more than six months'
        END AS activity_period,
        a.last_price / f.total_area AS price_per_sqm,		-- Price per square meter
        f.total_area,
        f.rooms,
        f.balcony,
        f.floor
    FROM real_estate.advertisement a
    JOIN real_estate.flats f ON a.id = f.id
    JOIN real_estate.city c ON f.city_id = c.city_id
    JOIN real_estate.type t ON f.type_id = t.type_id
    WHERE f.id IN (SELECT id FROM filtered_id) 
    	AND (c.city = 'Санкт-Петербург' OR (t.type = 'город' AND c.city != 'Санкт-Петербург')) 		-- Keep only Saint Petersburg and cities in Leningrad Region
)		-- Define data by region and activity periods
SELECT 
    region,
    activity_period,
    COUNT(*) AS ad_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY region), 2) AS ad_percentage,		-- Percentage of ads per region
    ROUND(AVG(price_per_sqm)::numeric, 2) AS avg_price_per_sqm,
    ROUND(AVG(total_area)::numeric, 2) AS avg_area,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY rooms) AS median_rooms,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY balcony) AS median_balcony,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY floor) AS median_floor
FROM categorized
GROUP BY region, activity_period
ORDER BY region DESC, 
         CASE 
             WHEN activity_period = 'up to a month' THEN 1		-- Sort by activity period
             WHEN activity_period = 'up to three months' THEN 2
             WHEN activity_period = 'up to six months' THEN 3
             WHEN activity_period = 'no category' THEN 4
             ELSE 5
         END;		-- Final query to output listing data and property characteristics for regional analysis

-- Task 2: Listing seasonality
-- The query should answer these questions:
-- 1. In which months is listing publication activity the highest? 
--    And removal activity? This shows buyer activity dynamics.
-- 2. Do periods of active listing publications coincide with periods 
--    of increased property sales (by month of listing removal)?
-- 3. How do seasonal fluctuations affect the average price per square meter and the average apartment size? 
--    What can be said about the dependence of these parameters on the month?

WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),		-- Limits to filter out outlier properties
activity_dates AS (
    SELECT 
        a.id, 
        a.first_day_exposition,
        CASE 
           WHEN a.days_exposition IS NOT NULL THEN (a.first_day_exposition + a.days_exposition::integer)::date
           ELSE NULL 
       END AS date_removed, 
        EXTRACT(MONTH FROM a.first_day_exposition::date) AS month_published,
        EXTRACT(MONTH FROM (a.first_day_exposition::date + a.days_exposition::integer)::date) AS month_removed,
        f.total_area,
        a.last_price
    FROM 
        real_estate.advertisement a
    JOIN 
        real_estate.flats f ON a.id = f.id
    JOIN 
        real_estate.type t ON f.type_id = t.type_id
    WHERE 
        f.total_area < (SELECT total_area_limit FROM limits)
        AND f.rooms < (SELECT rooms_limit FROM limits)
        AND f.balcony < (SELECT balcony_limit FROM limits)
        AND f.ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
        AND f.ceiling_height > (SELECT ceiling_height_limit_l FROM limits)
        AND (t.type = 'город')		-- Include only cities in the analysis
        AND EXTRACT(YEAR FROM a.first_day_exposition::date) NOT IN (2014, 2019)  -- Exclude incomplete years
),		-- Calculate listing removal dates and extract publication/removal months and property characteristics
publication_activity AS (
    SELECT 
        month_published AS month, 
        COUNT(*) AS publication_count,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS publication_rank,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()::numeric, 2) AS publication_percentage   -- Share of publications
    FROM 
        activity_dates
    GROUP BY 
        month_published
),		-- Count monthly publication activity and rank them
removal_activity AS (
    SELECT 
        month_removed AS month, 
        COUNT(*) AS removal_count,
        DENSE_RANK() OVER (ORDER BY COUNT(*) DESC) AS removal_rank,
        ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER ()::numeric, 2) AS removal_percentage    -- Share of removals
    FROM 
        activity_dates
    WHERE 
        month_removed IS NOT NULL
    GROUP BY 
        month_removed
),		-- Count monthly removal activity and rank them
average_price_per_month AS (
    SELECT 
        month_published AS month, 
        AVG(ad.last_price / f.total_area) AS avg_price_per_sqm,
        AVG(f.total_area) AS avg_area
    FROM 
        activity_dates ad
    JOIN 
        real_estate.flats f ON ad.id = f.id
    GROUP BY 
        month_published
)		-- Get seasonal results for average price and size
SELECT 
    p.month,
    p.publication_count,
    p.publication_rank,
    p.publication_percentage,
    r.removal_count,
    r.removal_rank,
    removal_percentage,
    ROUND(ap.avg_price_per_sqm::numeric, 2) as avg_price_per_sqm,
    ROUND(ap.avg_area::numeric, 2) as avg_area
FROM 
    publication_activity p
LEFT JOIN 
    removal_activity r ON p.month = r.month
LEFT JOIN 
    average_price_per_month ap ON p.month = ap.month
ORDER BY 
    p.month;		-- Final query that combines publication, removal, and price/size stats

-- Task 3: Leningrad Region real estate market analysis
-- The query should answer these questions:
-- 1. Which settlements in the Leningrad Region have the highest number of listings?
-- 2. Which settlements have the highest share of listings removed (sold)? 
--    This can indicate high sales rates.
-- 3. What are the average price per square meter and average apartment size in different settlements? 
--    Are there variations in these metrics?
-- 4. Among the highlighted settlements, which stand out in terms of listing duration? 
--    That is, where is real estate sold faster or slower?

WITH limits AS (
    SELECT  
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY total_area) AS total_area_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY rooms) AS rooms_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY balcony) AS balcony_limit,
        PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_h,
        PERCENTILE_DISC(0.01) WITHIN GROUP (ORDER BY ceiling_height) AS ceiling_height_limit_l
    FROM real_estate.flats     
),		-- Limits for outlier filtering
cities_data AS (
    SELECT 
        f.id,
        c.city AS location,
        CASE 
            WHEN c.city = 'Санкт-Петербург' THEN 'Saint Petersburg' 
            ELSE 'Leningrad Region' 
        END AS region,
        a.first_day_exposition,
        a.days_exposition,
        (a.first_day_exposition + a.days_exposition::integer)::date AS date_removed,
        f.total_area,
        f.rooms,
        f.balcony,
        f.floor,
        a.last_price,
        a.last_price / f.total_area AS price_per_sqm
    FROM 
        real_estate.advertisement a
    JOIN 
        real_estate.flats f ON a.id = f.id
    JOIN 
        real_estate.city c ON f.city_id = c.city_id
    WHERE 
        f.total_area < (SELECT total_area_limit FROM limits)
        AND f.rooms < (SELECT rooms_limit FROM limits)
        AND f.balcony < (SELECT balcony_limit FROM limits)
        AND f.ceiling_height < (SELECT ceiling_height_limit_h FROM limits)
        AND f.ceiling_height > (SELECT ceiling_height_limit_l FROM limits)
),		-- Extract listings linked with cities and property parameters
lenobl_data AS (
    SELECT
        location,
        COUNT(*) AS total_ads,
        COUNT(date_removed) AS removed_ads,
        COUNT(date_removed)::decimal / COUNT(*)::decimal AS removal_rate,		-- Share of removed ads
        AVG(days_exposition) AS avg_days_exposition,
        AVG(price_per_sqm) AS avg_price_per_sqm,
        AVG(total_area) AS avg_area,
        PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY rooms) AS median_rooms,
    	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY balcony) AS median_balcony,
    	PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY floor) AS median_floor
	FROM
        cities_data
    WHERE
        region = 'Leningrad Region'
    GROUP BY
        location
)		-- Extract Leningrad Region data and calculate listing statistics
SELECT 
    location,
    total_ads,
    removed_ads,
    ROUND(removal_rate * 100, 2) AS removal_rate,
    ROUND(avg_days_exposition::numeric, 2) AS avg_days_exposition,
    ROUND(avg_price_per_sqm::numeric, 2) AS avg_price_per_sqm,
    ROUND(avg_area::numeric, 2) AS avg_area,
    median_rooms,
    median_balcony,
    median_floor
FROM
    lenobl_data
ORDER BY
    removed_ads DESC
LIMIT 15;		-- Final query to extract and sort statistics for Leningrad Region; displays top 15 settlements by number of removed listings (sold apartments)
