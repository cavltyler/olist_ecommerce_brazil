CREATE EXTENSION IF NOT EXISTS unaccent;

---- TABLES CREATION

-- Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(2)
);

-- Orders Table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- Geolocation Table
CREATE TABLE geolocation (
	geolocation_zip_code_prefix INT,
	geolocation_lat NUMERIC (20,17),
	geolocation_lng NUMERIC (20,17),
	geolocation_city VARCHAR(100),
	geolocation_state VARCHAR(2)
);

-- Orders Reviews Table
CREATE TABLE order_reviews (
	review_id VARCHAR(50),
	order_id VARCHAR(50),
	review_score INTEGER,
	review_comment_title VARCHAR(500),
	review_comment_message VARCHAR(1000),
	review_creation_date TIMESTAMP,
	review_answer_timestamp TIMESTAMP
);

CREATE TABLE customer_state_region (
    state_code CHAR(2) PRIMARY KEY,
    region_code VARCHAR(2) NOT NULL
);


---- VIEWS CREATION
CREATE VIEW word_frequency AS
SELECT 
    word, 
    COUNT(word) AS word_frequency
FROM (
    SELECT regexp_split_to_table(LOWER(review_comment_message), '\W+') AS word
    FROM order_reviews
    WHERE review_comment_message IS NOT NULL
	AND review_score<=2
) AS word_list
WHERE word NOT IN ('o', 'a', 'e', 'que', 'do', 'da', 'de', 'não', 'muito', 'com', 'um', 'uma')
AND word != ''
GROUP BY word
ORDER BY word_frequency DESC;

CREATE VIEW categorised_issue_all_no_r_m AS
SELECT
	DISTINCT order_reviews.order_id,
	review_score,
	customer_state_region.state_code,
	customer_state_region.region_code,
	DATE_PART('day', orders.order_estimated_delivery_date-orders.order_purchase_timestamp) AS exp_leading_time,
	DATE_PART('day', orders.order_delivered_customer_date-orders.order_purchase_timestamp) AS act_leading_time,
	DATE_PART('day', orders.order_delivered_customer_date-orders.order_purchase_timestamp)-DATE_PART('day', orders.order_estimated_delivery_date-orders.order_purchase_timestamp) AS days_delayed,
	DATE_PART('day', order_reviews.review_creation_date-orders.order_estimated_delivery_date) AS review_days_past_estimated,
	DATE_PART('day', order_reviews.review_creation_date-orders.order_delivered_customer_date) AS review_days_past_delivered,
	CASE 
			WHEN DATE_PART('day', orders.order_delivered_customer_date-orders.order_purchase_timestamp) > 
			DATE_PART('day', orders.order_estimated_delivery_date-orders.order_purchase_timestamp)
			THEN 'Y'
			WHEN orders.order_delivered_customer_date IS NULL THEN 'U'
			ELSE 'N' END AS delivered_delayed,
	CASE WHEN DATE_PART('day', order_reviews.review_creation_date-orders.order_estimated_delivery_date)<0 THEN 'Y' ELSE 'N' END AS review_bf_est_del,
	CASE 
		  -- 1. MISTAKE IN REVIEW (Positive words)
    	WHEN unaccent(order_reviews.review_comment_message) ~* '\y(bo.|legal|obrigad.|gostei|recomendo|fant.stico|bonit.|parab.ns|lind.|(satisfeit.))\y'
			AND unaccent(order_reviews.review_comment_message) !~* '\y(n.o(e|foi|estou|fiquei)|n.ao(gostei|recomendo|))\y'
	    THEN 'Mistake in Review'
    
    	-- 2. COSTS
    	WHEN unaccent(order_reviews.review_comment_message) ~* '\y(pre.o|caro)\y'
			AND orders.order_delivered_customer_date IS NOT NULL
    	THEN 'Costs'
    
    	-- 3. DELIVERY & QUALITY (Both sets of keywords)
    	WHEN (unaccent(order_reviews.review_comment_message) ~* '\y(recebimento|aguardando|esperando|apenas|so|prazo|n.o (veio|chegou|re.ebi|entregue|foi)|atras.|demor.|dias|chegar|entreg.|
																receb.|rastrear|espera|onde|cad.|agora nada|aguard.|retirar|perdido|extraviado|demorou|demorando)\y'
			OR orders.order_delivered_customer_date IS NULL)
			AND unaccent(order_reviews.review_comment_message) ~* '\y(acabado|acabamento|defeito|inferior|qualidade|fr.gil|devolver|quebrad.|danificad.|horr.vel|p.ssim.|
		  														avariad.|fal.ificad.|avaria|estragad.|troca)\y'
    	THEN 'Delivery & Quality'
    
    	-- 4. DELIVERY ONLY
    	WHEN 
			unaccent(order_reviews.review_comment_message) ~* '\y(recebimento|aguardando|esperando|apenas|so|prazo|n.o (veio|chegou|entregue|foi)|atras.|demor.|dias|chegar|
															entreg.|receb.|rastrear|espera|onde|cad.|agora nada|aguard.|retirar|perdido|extraviado|demorou|demorando)\y'
          OR orders.order_delivered_customer_date IS NULL
    	THEN 'Delivery'		
    
  		-- 5. QUALITY ONLY
    	WHEN unaccent(order_reviews.review_comment_message) ~* '\y(acabado|acabamento|defeito|inferior|qualidade|fr.gil|devolver|quebrad.|danificad.|horr.vel|p.ssim.|
		  														avariad.|fal.ificad.|avaria|estragad.|troca)\y'
    	THEN 'Quality'
    
    	-- 6. DISPATCHING / AD
   		WHEN unaccent(order_reviews.review_comment_message) ~* '\y(an.ncio|erro|errad.|foto|anunciad.|diferente)\y'
   		THEN 'Dispatching/Ad'
    
    	ELSE 'Undetermined'
	END AS main_issue
FROM
	order_reviews
INNER JOIN
	orders
	ON orders.order_id = order_reviews.order_id
INNER JOIN
	customers
	ON customers.customer_id=orders.customer_id
INNER JOIN
	customer_state_region
	ON customers.customer_state=customer_state_region.state_code
WHERE
	order_reviews.review_comment_message IS NOT NULL
ORDER BY 
	review_score ASC,
	main_issue ASC;

CREATE VIEW cat_issue_delivery AS
SELECT
	order_id,
	main_issue,
	review_score,
	days_delayed,
	state_code,
	region_code,
	COUNT(DISTINCT order_id) AS total_orders,
	SUM(CASE WHEN review_days_past_estimated<0 THEN 1 ELSE 0 END) AS reviews_ontime,
	SUM(CASE WHEN review_days_past_estimated IS NULL THEN 1 ELSE 0 END) AS reviews_undelivered,
	SUM(CASE WHEN delivered_delayed IN ('Y') THEN 1 ELSE 0 END) AS order_delayed,
	SUM(CASE WHEN delivered_delayed IN ('N') THEN 1 ELSE 0 END) AS order_ontime,
	SUM(CASE WHEN delivered_delayed IN ('U') THEN 1 ELSE 0 END) AS order_undelivered,
	SUM(CASE WHEN delivered_delayed IN ('Y') THEN 1 ELSE 0 END)*100.00/COUNT(order_id) AS pct_delayed,
	SUM(CASE WHEN delivered_delayed IN ('N') THEN 1 ELSE 0 END)*100.00/COUNT(order_id) AS pct_ontime,
	SUM(CASE WHEN delivered_delayed IN ('U') THEN 1 ELSE 0 END)*100.00/COUNT(order_id) AS pct_undelivered,
	SUM(CASE WHEN review_score=1 THEN 1 ELSE 0 END) AS sc_1,
	SUM(CASE WHEN review_score=2 THEN 1 ELSE 0 END) AS sc_2,
	SUM(CASE WHEN review_score=3 THEN 1 ELSE 0 END) AS sc_3,
	SUM(CASE WHEN review_score=4 THEN 1 ELSE 0 END) AS sc_4,
	SUM(CASE WHEN review_score=5 THEN 1 ELSE 0 END) AS sc_5,
	SUM(CASE WHEN review_score=1 THEN 1 ELSE 0 END)*100.00/COUNT(order_id) AS pc_sc_1,
	SUM(CASE WHEN review_score=2 THEN 1 ELSE 0 END)*100.00/COUNT(order_id) AS pc_sc_2,
	SUM(CASE WHEN review_score=3 THEN 1 ELSE 0 END)*100.00/COUNT(order_id) AS pc_sc_3,
	SUM(CASE WHEN review_score=4 THEN 1 ELSE 0 END)*100.00/COUNT(order_id) AS pc_sc_4,
	SUM(CASE WHEN review_score=5 THEN 1 ELSE 0 END)*100.00/COUNT(order_id) AS pc_sc_5
FROM
	categorised_issue_all_no_r_m
GROUP BY
	order_id,
	main_issue,
	review_score,
	days_delayed,
	state_code,
	region_code
ORDER BY 
	main_issue;
