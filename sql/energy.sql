--check data from fct_summary
select * from fct_summary limit 10

--check data from energy source
select * from dim_energy_source

select * from dim_time

-- Sum of generation according to year and source
SELECT year, ROUND((SUM(nuclear_mwh)/1000000)::numeric,2) as total_nuclear,
ROUND((SUM(renewable_mwh)/1000000)::numeric,2) as total_renewable,
ROUND((SUM(fossil_mwh)/1000000)::numeric,2) as total_fossil,
ROUND((SUM(hydro_pumped_mwh)/1000000)::numeric,2) as total_hydropumped 
, ROUND((SUM(total_mwh)/1000000)::numeric,2) as total_enegy 
FROM fct_summary 
GROUP BY year 
ORDER BY year
--nuclear: decline, from 2023, Germany turned off nuclear --> mwh = 0

--average Renewable % according to month and year
SELECT 
 year, month, ROUND(AVG(renewable_pct)::numeric,2) as agv_renewable_pct
 from fct_summary
 group by year, month

--green_label according to year, % green each year 
select year, 
SUM(CASE WHEN green_label = 'Very Green' THEN 1 ELSE 0 END) as very_greeen
, SUM(CASE WHEN green_label = 'Green' THEN 1 ELSE 0 END) AS green,
SUM(CASE WHEN green_label = 'Not Green' THEN 1 ELSE 0 END) AS not_greean
, ROUND( 
      SUM( CASE WHEN green_label != 'Not Green' THEN 1 ELSE 0 END) *100.0 / COUNT(*), 2) as green_pct

from fct_summary 
group by year 
order by year 

--MoM month over month renewable % growth compare renewable % of this month with another onth
WITH MoM_renewable_pct AS (
SELECT year, month, 
		ROUND(avg(renewable_pct)::numeric, 2) as average_renewable_pct,
		LAG(ROUND(avg(renewable_pct)::numeric, 2)) OVER(PARTITION BY year order by month ) as avg_renewable_last_month
FROM fct_summary 
GROUP BY year, month )

SELECT *, (average_renewable_pct - avg_renewable_last_month) as diff_pct 
FROM MoM_renewable_pct 
    

--Q5: YoY growth của wind (offshore + onshore)--
select * from fct_summary limit 10

WITH yearly_wind_mwh AS (
SELECT year, ROUND((SUM(wind_onshore_mwh + wind_offshore_mwh)/1000000)::numeric,2) as total_wind_mwh 
, LAG(ROUND((SUM(wind_onshore_mwh + wind_offshore_mwh)/1000000)::numeric,2)) OVER(ORDER BY year) as previous_total_wind
from fct_summary 
GROUP BY year )

SELECT *, ROUND(((total_wind_mwh - previous_total_wind) *100/previous_total_wind)::numeric ,2) as diff__pct_wind
FROM yearly_wind_mwh 
ORDER BY year

-- --top 5 days having highest solar energy each year --
WITH ranking_solar AS (
SELECT year, DATE(timestamp_start) as date, ROUND(SUM(solar_mwh)::numeric, 2) as total_solar_mwh 
, RANK() OVER(PARTITION BY year ORDER BY ROUND(SUM(solar_mwh)::numeric, 2) DESC ) as solar_rank
FROM fct_summary
GROUP BY year, DATE(timestamp_start) )

SELECT year, date, total_solar_mwh 
FROM ranking_solar 
WHERE solar_rank BETWEEN 1 AND 5

--Running total renewable generation yearly -- pct annually monthly, checking how many % achieved comparing to target
WITH monthly_renewable AS (
SELECT year, month, ROUND((SUM(renewable_mwh)/1000000)::numeric, 2) AS  renewable_twh
FROM fct_summary 
GROUP BY year, month )

, monthly_running_total AS (
SELECT *,  SUM (renewable_twh) OVER(PARTITION BY year ORDER BY month) AS running_total
FROM monthly_renewable )

SELECT *, 
ROUND((running_total *100 / MAX(running_total) OVER (PARTITION BY year))::numeric,2) AS pct_running_total
FROM monthly_running_total

 --Summer & Winter renewable mix according to solar and wind energy--
 select * from fct_summary

SELECT year, 
 MAX(CASE WHEN season = 'Summer' THEN avg_renewable_pct END) AS summer_renewable_pct
 , MAX(CASE WHEN season = 'Winter' THEN avg_renewable_pct END) AS winter_renewable_pct
 , MAX(CASE WHEN season = 'Summer' THEN avg_solar_mwh END) AS sumer_avg_solar
 , MAX(CASE WHEN season = 'Winter' THEN avg_wind_mwh END) AS winter_avg_wind

 FROM (

SELECT year, season,
     ROUND(AVG(renewable_pct)::numeric,2) as avg_renewable_pct 
	 , ROUND(AVG(solar_mwh)::numeric, 2) as avg_solar_mwh
	 , ROUND(AVG(wind_offshore_mwh + wind_onshore_mwh)::numeric,2) as avg_wind_mwh
FROM fct_summary 
WHERE  season IN ('Summer', 'Winter')
GROUP BY year, season ) sub

GROUP BY year
ORDER BY year 

-- peak solar hour according to season --
SELECT season,hour, avg_solar_mwh FROM 
(
SELECT  season, hour, 
ROUND(AVG(solar_mwh)::numeric, 2) AS avg_solar_mwh 
, RANK () OVER(PARTITION BY  season ORDER BY ROUND(AVG(solar_mwh)::numeric, 2) DESC ) as rank_avg_solar
FROM fct_summary 
GROUP BY  season,hour ) sub
WHERE rank_avg_solar <=3
ORDER BY avg_solar_mwh DESC

-- Lignite decline yearly --
With yearly_avg_lignite AS (
SELECT year, 
ROUND(AVG(lignite_mwh)::numeric,2) AS avg_lignite_mwh 
FROM fct_summary 
GROUP BY year )

SELECT year, avg_lignite_mwh, 
LEAD(avg_lignite_mwh) OVER( ORDER BY year) AS next_avg_lignite
FROM yearly_avg_lignite 

--peak green hour and lowerest green hour --

SELECT hour, 
ROUND(AVG(renewable_pct)::numeric, 2) AS avg_renewable_pct 
FROM fct_summary 
GROUP BY hour
ORDER BY avg_renewable_pct DESC

-- longest streak consecutive green intervals 
select * from fct_summary

select timestamp_start, 
green_label , 
ROW_NUMBER() OVER (ORDER BY timestamp_start)
        - ROW_NUMBER() OVER (
            PARTITION BY green_label
            ORDER BY timestamp_start
        ) AS grp
from fct_summary

WITH grouped AS (
    SELECT
        timestamp_start,
        green_label,

        ROW_NUMBER() OVER (ORDER BY timestamp_start)
        -
        ROW_NUMBER() OVER (
            PARTITION BY green_label
            ORDER BY timestamp_start
        ) AS grp
    FROM fct_summary
),

streaks AS (
    SELECT
        green_label,
        grp,
        MIN(timestamp_start) AS start_time,
        MAX(timestamp_start) AS end_time,
        COUNT(*) AS intervals
    FROM grouped
    GROUP BY green_label, grp
)

SELECT *
FROM streaks
WHERE green_label IN ('Green', 'Very Green')
ORDER BY intervals DESC
;

--Renewable % percentile distribution each year -

SELECT year ,
ROUND(MIN(renewable_pct)::numeric,2) as p0,
ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY renewable_pct)::numeric,2) as p25_pct
, ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY renewable_pct)::numeric,2) as p50_pct
, ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY renewable_pct)::numeric,2) as p75_pct
, ROUND(MAX(renewable_pct)::numeric,2) as pmax
from fct_summary 
group by year 
order by year 

--- avg_renewable_pct, green_interval_pct, yoy_renewable_growth, yoy_wind_growth, fossil_ahre_pct --
With yearly AS (
SELECT year, 
ROUND(avg(renewable_pct)::numeric,2) as avg_renewable_pct
, SUM(fossil_mwh) as total_fossil
, SUM(total_mwh) as total_mwh
FROM fct_summary 
GROUP BY year ) 

, green_interval AS (
SELECT year, 
SUM(CASE WHEN green_label != 'Not Green' THEN 1 ELSE 0 END) AS green_intervals
, COUNT(*) AS total_intervals
FROM fct_summary 
GROUP BY year
ORDER BY year )
,
 yearly_wind_mwh AS (
SELECT year, ROUND((SUM(wind_onshore_mwh + wind_offshore_mwh)/1000000)::numeric,2) as total_wind_mwh 
, LAG(ROUND((SUM(wind_onshore_mwh + wind_offshore_mwh)/1000000)::numeric,2)) OVER(ORDER BY year) as previous_total_wind
from fct_summary 
GROUP BY year )

SELECT y.year, 
avg_renewable_pct, ROUND((green_intervals*100/total_intervals)::numeric,2) AS green_interval_pct
, (avg_renewable_pct - LAG(avg_renewable_pct) OVER( order by y.year))   as yoy_renewable_growth 
, ROUND(((total_wind_mwh - previous_total_wind) *100/previous_total_wind)::numeric ,2) as yoy_wind_growth
, ROUND((total_fossil*100/total_mwh)::numeric,2) as fossil_share_pct
FROM yearly y 
JOIN green_interval gi  ON y.year = gi.year
JOIN yearly_wind_mwh yw ON gi.year = yw.year








	 