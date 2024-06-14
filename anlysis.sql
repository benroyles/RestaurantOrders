use restaurant_analysis;

SELECT *
FROM order_details;

ALTER TABLE order_details
RENAME COLUMN ï»¿order_details_id to order_details_id;

SELECT * 
FROM menu_items;

ALTER TABLE menu_items
RENAME COLUMN ï»¿menu_item_id to menu_item_id;

SELECT *
FROM restaurant_db_data_dictionary;

################################### 1 ################################

### Most orders Items
SELECT menu_items.item_name, counts.count, menu_items.category	
FROM (SELECT item_id, COUNT(item_id) as count
	FROM order_details
	GROUP BY item_id)
	AS counts
JOIN menu_items on menu_items.menu_item_id = counts.item_id
ORDER BY counts.count DESC
limit 5
;

### Least orders Items
SELECT menu_items.item_name, counts.count, menu_items.category	
FROM (SELECT item_id, COUNT(item_id) as count
	FROM order_details
	GROUP BY item_id)
	AS counts
JOIN menu_items on menu_items.menu_item_id = counts.item_id
ORDER BY counts.count 
limit 5
;

SELECT *
FROM order_details;

SELECT *
FROM menu_items;

############################### 2 ##################################

## Highest Value Orders and the items they order

	WITH highest_order AS (SELECT order_id, ROUND(SUM(price),2) AS order_value		
	FROM
			(SELECT order_details.*, menu_items.item_name, menu_items.price
			FROM order_details
			JOIN menu_items on menu_items.menu_item_id = order_details.item_id) as cost
	GROUP BY order_id
	ORDER BY order_value DESC
    LIMIT 10)
    
    SELECT od.order_id, od.item_id, mi.item_name, mi.price
    FROM order_details od
    JOIN menu_items mi ON mi.menu_item_id=od.item_id
    JOIN highest_order ho ON ho.order_id = od.order_id;


### Most common items from big orders

	WITH highest_order AS (SELECT order_id, ROUND(SUM(price),2) AS order_value		
	FROM
			(SELECT order_details.*, menu_items.item_name, menu_items.price
			FROM order_details
			JOIN menu_items on menu_items.menu_item_id = order_details.item_id) as cost
	GROUP BY order_id
	ORDER BY order_value DESC
    LIMIT 25)
    
    SELECT mi.item_name, COUNT(mi.item_name) as item_count, ROUND(SUM(mi.price),2) as revenue
    FROM order_details od
    JOIN menu_items mi ON mi.menu_item_id=od.item_id
    JOIN highest_order ho ON ho.order_id = od.order_id
    GROUP BY mi.item_name
    ORDER BY revenue DESC
;

############################## 3 ##########################################

### Adding date and time fields with correct data type
SELECT *
FROM order_details;

SELECT str_to_date(order_date, '%m/%d/%y')
FROM order_details;

SET SQL_SAFE_UPDATES = 0;

ALTER TABLE order_details ADD COLUMN realdate DATE;
UPDATE order_details
SET realdate = STR_TO_DATE(order_date, '%m/%d/%y');

ALTER TABLE order_details ADD COLUMN realtime TIME;

UPDATE order_details
SET realtime = STR_TO_DATE(order_time, '%r');

SET SQL_SAFE_UPDATES = 1;

### Order Volumes by time
SELECT HOUR(realtime) as time_of_day, 
count(DISTINCT(order_id)) as number_of_orders,
count(order_details_id) as number_of_items_ordered
FROM order_details
GROUP BY HOUR(realtime);


### Revenue by time
SELECT HOUR(cost.realtime) as time_of_day,
		ROUND(SUM(cost.price),2) as revenue,
        COUNT(DISTINCT(cost.order_id)) as number_of_orders,
        ROUND(count(order_details_id)/COUNT(DISTINCT(cost.order_id))) AS average_order_size,
       ROUND((SUM(cost.price)/COUNT(DISTINCT(cost.order_id))),2) as average_order_value
FROM
	(SELECT od.*, mi.price
	FROM order_details od
	JOIN menu_items mi on od.item_id=mi.menu_item_id) AS cost
 GROUP BY time_of_day
 ORDER BY revenue DESC
;

### Order volumes and revenue by day
SELECT DAYNAME(cost.realdate) as day_of_week,
		ROUND(SUM(cost.price),2) as revenue,
        COUNT(DISTINCT(cost.order_id)) as number_of_orders,
        ROUND(count(order_details_id)/COUNT(DISTINCT(cost.order_id))) AS average_order_size,
       ROUND((SUM(cost.price)/COUNT(DISTINCT(cost.order_id))),2) as average_order_value
FROM
	(SELECT od.*, mi.price
	FROM order_details od
	JOIN menu_items mi on od.item_id=mi.menu_item_id) AS cost
 GROUP BY day_of_week
 ORDER BY revenue DESC;
 
######################################### 4 ###########################################

### Items and revnue
SELECT items.item_name, items.category, COUNT(items.item_name) as number_ordered,
ROUND(SUM(items.price),2) as revenue
FROM (SELECT od.*, mi.*
	FROM order_details od
	JOIN menu_items mi on mi.menu_item_id=od.item_id) as items
GROUP BY items.item_name, items.category
ORDER BY revenue DESC
;
 
 ### Categories and revenue
SELECT items.category, COUNT(DISTINCT(items.item_name)) as number_of_items, COUNT(items.category) as number_ordered,
ROUND(SUM(items.price),2) as revenue,
ROUND((SUM(items.price)/COUNT(items.category)),2) as average_price
FROM (SELECT od.*, mi.*
	FROM order_details od
	JOIN menu_items mi on mi.menu_item_id=od.item_id) as items
GROUP BY items.category
ORDER BY revenue DESC
;


##### FOUND NULL VALUES, CREATING A BACKUP AND THEN REMOVING FROM MAIN TABLE

-- Step 1: Preview rows to be deleted
SELECT *
FROM order_details
WHERE item_id IS NULL;

-- Step 2: Backup the table (optional but recommended)
CREATE TABLE order_details_backup AS
SELECT *
FROM order_details;

-- Turning off safe mode
SET SQL_SAFE_UPDATES = 0;

-- Step 3: Delete the rows where item_id is null
DELETE FROM order_details
WHERE item_id IS NULL;

-- Step 4: Verify the deletion
SELECT *
FROM order_details
WHERE item_id IS NULL;

-- Turning safe mode back on
SET SQL_SAFE_UPDATES = 1;

### Order frequency and revenue generated

WITH 
num_of_orders AS (
    SELECT COUNT(DISTINCT order_id) AS total_orders 
    FROM order_details
), 
total_items_ordered AS (
    SELECT COUNT(order_details_id) AS total_items
    FROM order_details
),
total_revenue AS (
    SELECT SUM(mi.price) AS total_revenue
    FROM order_details od
    JOIN menu_items mi ON mi.menu_item_id = od.item_id
)

SELECT 
    mi.item_name,
    mi.price,
    mi.category,
    COUNT(od.order_id) AS number_of_orders, 
    COUNT(od.item_id) / (SELECT total_items FROM total_items_ordered) AS proportion_of_total_items,
    COUNT(mi.item_name) / (SELECT total_orders FROM num_of_orders) AS order_frequency,
    ROUND(SUM(mi.price), 2) AS revenue,
    ROUND(SUM(mi.price) / (SELECT total_revenue FROM total_revenue),4) AS revenue_proportion
FROM 
    order_details od
JOIN 
    menu_items mi ON mi.menu_item_id = od.item_id
GROUP BY 
    mi.item_name, mi.price, mi.category
ORDER BY 
    revenue_proportion DESC;
    
################# Creating table to export as csv ######################

-- Turning off safe mode
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE order_details
DROP COLUMN order_date;

ALTER TABLE order_details
DROP COLUMN order_time;

SELECT od.*, mi.item_name, mi.category, mi.price
FROM order_details od
JOIN menu_items mi on mi.menu_item_id=od.item_id
LIMIT 100000000;

-- Turning safe mode back on
SET SQL_SAFE_UPDATES = 1;

######################### Ordered Together ########################

SELECT *
FROM menu_items;

## Creating a combined Table
CREATE TABLE order_summary AS
SELECT
    o.*,
    mi.item_name,
    mi.category,
    mi.price
FROM order_details o
JOIN menu_items mi ON o.item_id = mi.menu_item_id;

###### Multiples of same items in an order
SELECT order_id, item_name, COUNT(*)
FROM order_summary
GROUP BY order_id, item_name
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC;

######## ADDING QUANTITIES COLUMN ############
-- Step 1: Add the quantity column
ALTER TABLE order_summary ADD COLUMN quantity INT DEFAULT 1;

-- Step 2: Create a temporary table to calculate the quantity for each order_id and item_id
DROP TEMPORARY TABLE temp_order_quantities;
CREATE TEMPORARY TABLE temp_order_quantities AS
SELECT order_id, item_id, COUNT(*) AS quantity
FROM order_summary
GROUP BY order_id, item_id;

SELECT * 
FROM temp_order_quantities
ORDER BY quantity DESC;

-- Turning off safe mode
SET SQL_SAFE_UPDATES = 0;

-- Step 3: Update the orders table with the calculated quantities
UPDATE order_summary o
JOIN temp_order_quantities tq
ON o.order_id = tq.order_id AND o.item_id = tq.item_id
SET o.quantity = tq.quantity;

-- Step 1: Identify the duplicates
CREATE TEMPORARY TABLE temp_table AS
SELECT MIN(order_details_id) as order_details_id, order_id, item_id, realdate, realtime, item_name, category, price, quantity 
FROM order_summary
GROUP BY order_id, item_id, realdate, realtime, item_name, category, price, quantity;

-- Step 2: Truncate the original table
TRUNCATE TABLE order_summary;

-- Step 3: Insert unique rows back to the original table
INSERT INTO order_summary (order_details_id, order_id, item_id, realdate, realtime, item_name, category, price, quantity)
SELECT order_details_id, order_id, item_id, realdate, realtime, item_name, category, price, quantity FROM temp_table;

-- Step 4: Drop the temporary table
DROP TEMPORARY TABLE temp_table;

##### Order Combinations
SELECT c.original_item, c.bought_with, count(*) as times_bought_together
FROM (
  SELECT a.item_name as original_item, b.item_name as bought_with
  FROM order_summary a
  join order_summary b
  ON a.order_id = b.order_id 
  AND a.item_name != b.item_name
  AND a.item_name < b.item_name) c -- ensures that the combination only appears onces, item 1 + item 2 NOT item 1+2 and 2+1 
GROUP BY c.original_item, c.bought_with
ORDER BY times_bought_together DESC;

######## More than 1 of the same ite per order
SELECT item_name, quantity, COUNT(*) as multiple_per_order
FROM order_summary
WHERE quantity > 1
GROUP BY item_name, quantity
ORDER BY multiple_per_order DESC
;
 -- items only mainly ordered twice per order, relatively few instanaces of more than 2 of the same item in an order
 
 ######## Order combinations including where both items are the same
SELECT item_name as original_item, item_name as bought_with, COUNT(*) as times_bought_together
FROM order_summary
WHERE quantity > 1
GROUP BY item_name

UNION

SELECT c.original_item, c.bought_with, count(*) as times_bought_together
FROM (
  SELECT a.item_name as original_item, b.item_name as bought_with
  FROM order_summary a
  join order_summary b
  ON a.order_id = b.order_id 
  AND a.item_name != b.item_name
  AND a.item_name < b.item_name) c -- ensures that the combination only appears onces, item 1 + item 2 NOT item 1+2 and 2+1 
GROUP BY c.original_item, c.bought_with
ORDER BY original_item, times_bought_together DESC
;

############## 3 items bought together

SELECT AVG(num_items) AS avg_items_per_order
FROM (
    SELECT order_id, COUNT(*) AS num_items
    FROM order_summary
    GROUP BY order_id
) AS order_items_count;

#### Average order size is 2, some order are larger but the majority are not so I will not expand my analysis into more that 2 of the same item. the number of combinations also would increase exponentially



