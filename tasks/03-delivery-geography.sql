-- Exploratory Data Analysis (EDA): 
-- Verifying the difference in delivery performance ratios per geographic region.
-- This mathematical check informed the regional comparison visual in the final Tableau dashboard.

SELECT
	region_code,
	ROUND(AVG(pct_undelivered),2) AS avg_pct_undelivered,
	ROUND(AVG(pct_delayed),2) AS avg_pct_delayed,
	ROUND(AVG(pct_ontime),2) AS avg_pct_ontime
FROM cat_issue_delivery
GROUP BY region_code
ORDER BY avg_pct_ontime ASC;

-- ABOVE QUERY SHOWS THAT THE NE (NORTHEAST) REGION IS THE MORE IMPACTED WITH DELAYS AND FAIL TO DELIVER. ONLY 79.05% DELIVERED ON TIME.

SELECT
	state_code,
	ROUND(AVG(pct_undelivered),2) AS avg_pct_undelivered,
	ROUND(AVG(pct_delayed),2) AS avg_pct_delayed,
	ROUND(AVG(pct_ontime),2) AS avg_pct_ontime
FROM cat_issue_delivery
GROUP BY state_code
ORDER BY avg_pct_ontime ASC;

-- ABOVE QUERY SHOWS THAT AL (ALAGOAS) AND RR (RORAIMA) ARE THE TWO STATES MOST IMPACTED WITH DELAYS AND FAIL TO DELIVER. ONLY 66.5-66.7% ON TIME.

