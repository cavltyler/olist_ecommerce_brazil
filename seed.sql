COPY customers 
FROM 'datasets\olist_customers_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY orders 
FROM 'datasets\olist_orders_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY geolocation
FROM 'datasets\olist_geolocation_dataset.csv'
DELIMITER ',' CSV HEADER;

COPY order_reviews
FROM 'datasets\olist_order_reviews_dataset.csv'
DELIMITER ',' CSV HEADER;

INSERT INTO customer_state_region (state_code, region_code) 
VALUES 
    -- North (N)
    ('AC', 'N'), ('AP', 'N'), ('AM', 'N'), ('PA', 'N'), ('RO', 'N'), ('RR', 'N'), ('TO', 'N'),
    
    -- Northeast (NE)
    ('AL', 'NE'), ('BA', 'NE'), ('CE', 'NE'), ('MA', 'NE'), ('PB', 'NE'), ('PE', 'NE'), ('PI', 'NE'), ('RN', 'NE'), ('SE', 'NE'),
    
    -- Center-West (CO)
    ('DF', 'CO'), ('GO', 'CO'), ('MT', 'CO'), ('MS', 'CO'),
    
    -- Southeast (SE)
    ('ES', 'SE'), ('MG', 'SE'), ('RJ', 'SE'), ('SP', 'SE'),
    
    -- South (S)
    ('PR', 'S'), ('RS', 'S'), ('SC', 'S');