USE zepto_sql_project;

DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
sku_id INT AUTO_INCREMENT PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp DECIMAL(8,2),
discount_percent DECIMAL(8,2),
available_quantity INT,
discounted_selling_price DECIMAL(8,2),
weight_in_grams INT,
out_of_stock VARCHAR(50),
quantity INT
);

-- 1. Data Exploration & Cleaning

-- Total Records
select count(*) as total_products
from zepto;

-- sample data
select* from zepto limit 10;

-- Unique Categories
select count(distinct category) as total_category
from zepto;

-- Check NULL Values
select sum(category is null) as category_nulls,
sum(name is null) as name_nulls,
sum(mrp is null) as mrp_nulls
from zepto;

-- Out of Stock Products
select count(*)
from zepto
where out_of_stock = 'TRUE';


-- 2. Inventory Analysis

-- Products Available by Category
SELECT category,
COUNT(*) AS total_products
FROM zepto
GROUP BY category
ORDER BY total_products DESC;

-- Categories with Highest Inventory
SELECT category,
SUM(quantity) AS total_inventory
FROM zepto
GROUP BY category
ORDER BY total_inventory DESC;

-- Low Stock Products
SELECT *
FROM zepto
WHERE quantity < 5
ORDER BY quantity;


-- 3. Pricing Analysis

-- Most Expensive Products
SELECT name, category, mrp
FROM zepto
ORDER BY mrp DESC
LIMIT 10;

-- Average Product Price by Category
SELECT category, AVG(discounted_selling_price) AS avg_price
FROM zepto
GROUP BY category
ORDER BY avg_price DESC;


-- 4. Discount Analysis

-- Top Discounted Products
SELECT name, category,
discount_percent
FROM zepto
ORDER BY discount_percent DESC
LIMIT 10;

-- Average Discount by Category
SELECT category,
AVG(discount_percent) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC;


-- 5. Revenue Analysis

-- Revenue by Category
SELECT category,
SUM(discounted_selling_price * quantity) AS revenue
FROM zepto
GROUP BY category
ORDER BY revenue DESC;

-- Top Revenue Products
SELECT name, category,
(discounted_selling_price * quantity) AS revenue
FROM zepto
ORDER BY revenue DESC
LIMIT 10;


-- 6. CTE Query

-- Top 5 Revenue Categories
WITH category_revenue AS (
  SELECT category,
    SUM(discounted_selling_price * quantity) AS revenue
    FROM zepto
    GROUP BY category
    )
SELECT *
FROM category_revenue
ORDER BY revenue DESC
LIMIT 5;


-- 7. Window Function Query

-- Rank Categories by Revenue
WITH category_revenue AS(
    SELECT category,
    SUM(discounted_selling_price * quantity) AS revenue
    FROM zepto
    GROUP BY category
)
SELECT category, revenue,
RANK() OVER(
ORDER BY revenue DESC
) AS revenue_rank
FROM category_revenue;

-- 8. Revenue Contribution %
WITH category_revenue AS(
    SELECT
    category,
    SUM(discounted_selling_price * quantity) AS revenue
    FROM zepto
    GROUP BY category
)
SELECT category, revenue,
ROUND(
100 * revenue /
SUM(revenue) OVER(),
2) AS revenue_contribution_pct
FROM category_revenue
ORDER BY revenue DESC;


-- 9. Product Performance Analysis

-- Best Product in Each Category
WITH product_revenue AS(
SELECT category, name,
discounted_selling_price*quantity AS revenue
FROM zepto
),
product_ranking AS(
SELECT*,
ROW_NUMBER() OVER(
PARTITION BY category
ORDER BY revenue DESC) AS rn
FROM product_revenue
)
SELECT*
FROM product_ranking
WHERE rn = 1;


-- 10. Business Insight's

-- High Discount but Low Revenue Products
SELECT name, category, discount_percent,
(discounted_selling_price * quantity) AS revenue
FROM zepto
WHERE discount_percent > 40
ORDER BY revenue ASC;

-- 11. Inventory Analysis
SELECT category,
    COUNT(*) AS total_products,
     SUM(out_of_stock = 'FALSE') AS in_stock_products,
     SUM(out_of_stock = 'TRUE') AS out_of_stock_products
FROM zepto
GROUP BY category
ORDER BY total_products DESC;
