-- Exploratory Data Analysis (EDA): 
-- Establishing the baseline distribution of negative sentiment.
-- This query calculates the exact split between 1-star and 2-star reviews (80.31% vs 19.69%).

SELECT
	COUNT(DISTINCT review_id) AS total_low_reviews,
	COUNT(DISTINCT review_id) FILTER(WHERE review_score=1) AS score_1,
	COUNT(DISTINCT review_id) FILTER(WHERE review_score=2) AS score_2,
	ROUND((COUNT(DISTINCT review_id) FILTER(WHERE review_score=1)::NUMERIC(8,2) / COUNT(DISTINCT review_id)::NUMERIC(8,2)) * 100, 2) AS perc_score_1,
	ROUND((COUNT(DISTINCT review_id) FILTER(WHERE review_score=2)::NUMERIC(8,2) / COUNT(DISTINCT review_id)::NUMERIC(8,2)) * 100, 2) AS perc_score_2
FROM 
	order_reviews
WHERE 
	review_score <= 2
	AND review_comment_message IS NOT NULL;


-- Text Mining & NLP:
-- Identifying the top 50 most frequent words in low-score reviews.
-- This output directly informed the Regular Expression (Regex) keyword logic used to bucket the core operational issues.

SELECT *
FROM word_frequency
ORDER BY word_frequency DESC
LIMIT 50;