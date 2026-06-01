-- =============================================
-- PROJECT 3 — RETAIL SALES ANALYSIS
-- Tool: PostgreSQL
-- Dataset: Kaggle Retail Orders
-- =============================================


-- =============================================
-- PHASE 1: DATABASE SETUP
-- =============================================

-- Create staging table
CREATE TABLE staging_orders (
    order_id VARCHAR(20),
    order_date VARCHAR(20),
    ship_mode VARCHAR(50),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_id VARCHAR(20),
    cost_price DECIMAL(10,2),
    list_price DECIMAL(10,2),
    quantity INTEGER,
    discount DECIMAL(5,2)
);

-- Load CSV into staging table
COPY staging_orders
FROM 'C:\orders.csv'
DELIMITER ','
CSV HEADER;

-- Create products table
CREATE TABLE products (
    product_id VARCHAR(20) PRIMARY KEY,
    category VARCHAR(50),
    sub_category VARCHAR(50)
);

INSERT INTO products (product_id, category, sub_category)
SELECT DISTINCT product_id, category, sub_category
FROM staging_orders;

-- Create regions table
CREATE TABLE regions (
    region_id SERIAL PRIMARY KEY,
    region VARCHAR(50),
    country VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50)
);

INSERT INTO regions (region, country, state, city)
SELECT DISTINCT region, country, state, city
FROM staging_orders;

-- Create orders table
CREATE TABLE orders (
    order_id VARCHAR(20) PRIMARY KEY,
    order_date DATE,
    ship_mode VARCHAR(50),
    segment VARCHAR(50),
    region VARCHAR(50)
);

INSERT INTO orders (order_id, order_date, ship_mode, segment, region)
SELECT DISTINCT order_id, TO_DATE(order_date, 'YYYY-MM-DD'), ship_mode, segment, region
FROM staging_orders;

-- Create order_items table
CREATE TABLE order_items (
    item_id SERIAL PRIMARY KEY,
    order_id VARCHAR(20) REFERENCES orders(order_id),
    product_id VARCHAR(20) REFERENCES products(product_id),
    quantity INTEGER,
    cost_price DECIMAL(10,2),
    list_price DECIMAL(10,2),
    discount DECIMAL(5,2)
);

INSERT INTO order_items (order_id, product_id, quantity, cost_price, list_price, discount)
SELECT order_id, product_id, quantity, cost_price, list_price, discount
FROM staging_orders;


-- =============================================
-- PHASE 2: DATA CLEANING
-- =============================================

-- Check NULL values in each table
SELECT COUNT(*) AS total_rows,
    COUNT(order_id) AS non_null_order_id,
    COUNT(order_date) AS non_null_order_date,
    COUNT(ship_mode) AS non_null_ship_mode,
    COUNT(segment) AS non_null_segment,
    COUNT(region) AS non_null_region
FROM orders;

SELECT COUNT(*) AS total_rows,
    COUNT(order_id) AS non_null_order_id,
    COUNT(product_id) AS non_null_product_id,
    COUNT(quantity) AS non_null_quantity,
    COUNT(cost_price) AS non_null_cost_price,
    COUNT(list_price) AS non_null_list_price,
    COUNT(discount) AS non_null_discount
FROM order_items;

SELECT COUNT(*) AS total_rows,
    COUNT(product_id) AS non_null_product_id,
    COUNT(category) AS non_null_category,
    COUNT(sub_category) AS non_null_sub_category
FROM products;

SELECT COUNT(*) AS total_rows,
    COUNT(region) AS non_null_region,
    COUNT(country) AS non_null_country,
    COUNT(state) AS non_null_state,
    COUNT(city) AS non_null_city
FROM regions;

-- Check duplicates
SELECT order_id, COUNT(*) AS duplicate_count
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT order_id, product_id, COUNT(*) AS duplicate_count
FROM order_items
GROUP BY order_id, product_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*) AS duplicate_count
FROM products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT region, country, state, city, COUNT(*) AS duplicate_count
FROM regions
GROUP BY region, country, state, city
HAVING COUNT(*) > 1;

-- Check data consistency
SELECT
    MIN(quantity) AS min_quantity,
    MAX(quantity) AS max_quantity,
    MIN(cost_price) AS min_cost,
    MAX(cost_price) AS max_cost,
    MIN(list_price) AS min_list,
    MAX(list_price) AS max_list,
    MIN(discount) AS min_discount,
    MAX(discount) AS max_discount
FROM order_items;

-- Check zero price rows
SELECT COUNT(*) AS zero_price_rows
FROM order_items
WHERE cost_price = 0 OR list_price = 0;

-- Delete zero price rows
DELETE FROM order_items
WHERE cost_price = 0 OR list_price = 0;

-- Verify remaining rows (should be 9487)
SELECT COUNT(*) FROM order_items;

-- Fix dirty ship_mode values
UPDATE orders
SET ship_mode = NULL
WHERE ship_mode IN ('Not Available', 'N/A', 'unknown');


-- =============================================
-- PHASE 3: EDA — 10 BUSINESS QUESTIONS
-- =============================================

-- Q1: Which product category has the highest sales?
SELECT 
    p.category,
    SUM(oi.list_price * oi.quantity) AS total_sales
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY total_sales DESC;

-- Q2: In which month are sales at peak?
SELECT 
    EXTRACT(MONTH FROM o.order_date) AS month,
    TO_CHAR(o.order_date, 'Month') AS month_name,
    SUM(oi.list_price * oi.quantity) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month, month_name
ORDER BY total_sales DESC;

-- Q3: Shipping demand by month and ship mode
SELECT 
    TO_CHAR(o.order_date, 'Month') AS month_name,
    o.ship_mode,
    COUNT(*) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month_name, o.ship_mode
ORDER BY total_orders DESC
LIMIT 10;

-- Q4: Which region sold most and least?
SELECT 
    o.region,
    COUNT(oi.item_id) AS total_orders,
    SUM(oi.list_price * oi.quantity) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.region
ORDER BY total_sales DESC;

-- Q5: Is discount affecting revenue?
SELECT
    oi.discount,
    COUNT(*) AS total_orders,
    SUM(oi.list_price * oi.quantity) AS total_sales,
    AVG(oi.list_price * oi.quantity) AS avg_sale_per_order
FROM order_items oi
GROUP BY oi.discount
ORDER BY oi.discount ASC;

-- Q6: Are customers satisfied with discounts?
SELECT
    o.segment,
    AVG(oi.discount) AS avg_discount,
    COUNT(*) AS total_orders,
    SUM(oi.list_price * oi.quantity) AS total_sales
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.segment
ORDER BY total_sales DESC;

-- Q7: Which category has highest cost price per quantity?
SELECT
    p.category,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.cost_price) AS total_cost,
    ROUND(SUM(oi.cost_price) / SUM(oi.quantity), 2) AS cost_per_unit
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.category
ORDER BY cost_per_unit DESC;

-- Q8: Average discount by segment and category?
SELECT
    o.segment,
    p.category,
    ROUND(AVG(oi.discount), 2) AS avg_discount
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY o.segment, p.category
ORDER BY o.segment, avg_discount DESC;

-- Q9: Shipping pattern by month and ship mode
SELECT 
    TO_CHAR(o.order_date, 'Month') AS month_name,
    EXTRACT(MONTH FROM o.order_date) AS month_num,
    o.ship_mode,
    COUNT(*) AS total_orders,
    ROUND(AVG(oi.list_price * oi.quantity), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month_name, month_num, o.ship_mode
ORDER BY month_num, total_orders DESC;

-- Q10: Which category was mostly shipped via Standard Class (late risk)?
SELECT
    p.category,
    o.ship_mode,
    COUNT(*) AS total_orders
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.ship_mode = 'Standard Class'
GROUP BY p.category, o.ship_mode
ORDER BY total_orders DESC;


-- =============================================
-- PHASE 4: CTEs
-- =============================================

-- CTE 1: Categories with sales above 3.7M
WITH category_sales AS (
    SELECT 
        p.category,
        SUM(oi.list_price * oi.quantity) AS total_sales
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category
)
SELECT *
FROM category_sales
WHERE total_sales > 3700000;

-- CTE 2: Regions with above average sales
WITH regional_sales AS (
    SELECT 
        o.region,
        SUM(oi.list_price * oi.quantity) AS total_sales
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.region
),
avg_sales AS (
    SELECT AVG(total_sales) AS average_sales
    FROM regional_sales
)
SELECT 
    r.region,
    r.total_sales,
    a.average_sales
FROM regional_sales r, avg_sales a
WHERE r.total_sales > a.average_sales;

-- CTE 3: Categories with above average cost per unit
WITH cost_per_unit_category AS (
    SELECT 
        p.category,
        ROUND(SUM(oi.cost_price) / SUM(oi.quantity), 2) AS cost_per_unit
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category
),
avg_cost AS (
    SELECT AVG(cost_per_unit) AS average_cost
    FROM cost_per_unit_category
)
SELECT 
    c.category,
    c.cost_per_unit,
    a.average_cost
FROM cost_per_unit_category c, avg_cost a
WHERE c.cost_per_unit > a.average_cost;


-- =============================================
-- PHASE 5: WINDOW FUNCTIONS
-- =============================================

-- ROW_NUMBER: Rank orders by sales within each region
SELECT 
    o.order_id,
    o.region,
    SUM(oi.list_price * oi.quantity) AS total_sales,
    ROW_NUMBER() OVER (
        PARTITION BY o.region 
        ORDER BY SUM(oi.list_price * oi.quantity) DESC
    ) AS row_num
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.region
ORDER BY o.region, row_num
LIMIT 12;

-- ROW_NUMBER + CTE: Top 1 order per region
WITH ranked_orders AS (
    SELECT 
        o.order_id,
        o.region,
        SUM(oi.list_price * oi.quantity) AS total_sales,
        ROW_NUMBER() OVER (
            PARTITION BY o.region 
            ORDER BY SUM(oi.list_price * oi.quantity) DESC
        ) AS row_num
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id, o.region
)
SELECT *
FROM ranked_orders
WHERE row_num = 1;

-- RANK: Rank sub-categories by sales within each category
WITH category_sales AS (
    SELECT 
        p.category,
        p.sub_category,
        SUM(oi.list_price * oi.quantity) AS total_sales
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY p.category, p.sub_category
)
SELECT 
    category,
    sub_category,
    total_sales,
    RANK() OVER (
        PARTITION BY category
        ORDER BY total_sales DESC
    ) AS sales_rank
FROM category_sales
ORDER BY category, sales_rank
LIMIT 10;
