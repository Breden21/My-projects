/*
Electronic goods sales data exploration using PostgreSQL in DBeaver

Skills exhibited: Common Table Expressions, Subqueries, Views, Aggregate Functions, Window Functions, String Functions

*/

-- Showing a list of all the products sold and their prices

SELECT DISTINCT ("Product"),"Price Each"
FROM e_goods_sales_dataset 
WHERE "Order ID" IS NOT NULL

--------------------------------------------------------------------------------------------------------------------------

--Showing the most expensive product sold

SELECT DISTINCT  "Product", "Price Each"
FROM e_goods_sales_dataset 
WHERE "Price Each" = (SELECT MAX("Price Each") 
						FROM e_goods_sales_dataset)

--------------------------------------------------------------------------------------------------------------------------

--Showing the cheapest product sold
select distinct  "Product", "Price Each"
from e_goods_sales_dataset 
where "Price Each" = (SELECT MIN("Price Each") 
						FROM e_goods_sales_dataset)

--------------------------------------------------------------------------------------------------------------------------

--Listing sales (from most to least) by number of units sold per product

SELECT "Product", SUM("Quantity Ordered") AS "Total Goods Sold"
FROM unidb.e_goods_sales_dataset
GROUP BY "Product" 
HAVING SUM("Quantity Ordered") >= 1
ORDER BY 2 DESC

--------------------------------------------------------------------------------------------------------------------------

--Total sales in monetary terms(USD)

SELECT SUM(total_sales)
FROM
	(SELECT DISTINCT ("Product") ,"Price Each", 
	total_products_sold,
	("Price Each" *total_products_sold) AS total_sales
	FROM
		(SELECT *,
		SUM("Quantity Ordered") OVER (PARTITION BY "Product") AS total_products_sold
		FROM unidb.e_goods_sales_dataset)a)b
WHERE "Price Each" IS NOT NULL

--------------------------------------------------------------------------------------------------------------------------

--Showing the top 10 selling products by revenue generated

WITH CTE_sales
AS
(
SELECT *,
SUM("Quantity Ordered") OVER (PARTITION BY "Product") AS total_products_sold
FROM unidb.e_goods_sales_dataset
) 
SELECT DISTINCT("Product"),"Price Each", 
total_products_sold,
("Price Each" *total_products_sold) AS total_sales
FROM cte_sales 
WHERE "Order ID" IS NOT NULL
ORDER BY 4 DESC
LIMIT 10

--------------------------------------------------------------------------------------------------------------------------

--Analysis by City and State

--Extracting city from the purchase address column and creatin view with "city1" column added to it for analysis based on Cities

CREATE view B AS 
(
SELECT *,
	SUM("Quantity Ordered") OVER (PARTITION BY "Product") AS total_products_sold,
	SPLIT_PART("Purchase Address",',',2) AS City1
FROM unidb.e_goods_sales_dataset
WHERE "Order ID" IS NOT NULL
)

--Listing the number of cities where sales were made

SELECT COUNT (DISTINCT(city1))
FROM B


--Listing the names of cities where sales were made

SELECT DISTINCT(city1)
FROM B


-- Ranking cities by number of sales made in each city(ranking is from highest to lowest)

SELECT city1, SUM("Quantity Ordered"),
RANK () OVER (ORDER BY (SUM("Quantity Ordered"))DESC)
FROM B 
GROUP BY city1 


-- Sales by City

SELECT SUM(sales), city1 
FROM
	(SELECT SUM("Quantity Ordered" *"Price Each" ) AS sales
	,"Product" ,city1 
	FROM
		(SELECT *,SPLIT_PART("Purchase Address",',',2) AS City1
		FROM e_goods_sales_dataset 
		WHERE "Order ID" IS NOT NULL)a  
	GROUP BY "Product" ,city1)b 
GROUP BY city1
ORDER BY 1 DESC


--Sales by State

SELECT sum(sales) AS sales_by_state, state 
FROM
	(SELECT sum("Quantity Ordered" *"Price Each" ) AS sales
	,"Product" ,state  
	FROM
		(SELECT *,
		LEFT (TRIM (SPLIT_PART("Purchase Address",',',3)),2) AS state
		FROM e_goods_sales_dataset 
		WHERE "Order ID" IS NOT NULL)a  
	GROUP BY "Product" ,state)b 
GROUP BY state
ORDER BY 1 DESC

--------------------------------------------------------------------------------------------------------------------------

-- Percentage contribution of each state to total sales

SELECT 100*(SUM(sales)/((SELECT SUM(sales)
	FROM
	(SELECT SUM("Quantity Ordered"*"Price Each") AS sales, "Product" 
	FROM e_goods_sales_dataset  
	WHERE "Order ID" IS NOT NULL 
	GROUP BY "Product" )c)))
AS percentage_by_state, state 
FROM
		(SELECT sum("Quantity Ordered" *"Price Each" ) AS sales
		,"Product" ,state  
		FROM
			(SELECT *,
			LEFT (TRIM (SPLIT_PART("Purchase Address",',',3)),2) AS state
			FROM e_goods_sales_dataset  
			WHERE "Order ID" IS NOT NULL)a  
		GROUP BY "Product" ,state)b 
GROUP BY state
ORDER BY 1 DESC