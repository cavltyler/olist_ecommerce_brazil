-- Validating the issue categorization logic for negative reviews (Scores 1 and 2)
-- This query demonstrates how the unstructured text was successfully bucketed into core operational issues.

SELECT 
    main_issue,
    review_score,
    COUNT(order_id) AS total_orders
FROM 
    categorised_issue_all_no_r_m
WHERE 
    review_score <= 2
	AND days_delayed IS NOT NULL
GROUP BY
    main_issue,
    review_score
ORDER BY
    total_orders DESC;

-- Taking a granular look at the categorized dataset alongside the delivery delay metrics.
-- Undelivered orders have been removed for better visualization.
SELECT
    order_id,
    review_score,
    main_issue,
    days_delayed,
    exp_leading_time,
    act_leading_time
FROM 
    categorised_issue_all_no_r_m
WHERE 
    review_score <= 2
	AND days_delayed IS NOT NULL
ORDER BY 
    days_delayed DESC
LIMIT 100;