# Restaurant Analysis Project

## Overview

This project analyzes a quarter's worth of orders from a fictitious restaurant serving international cuisine. The dataset includes details on the date and time of each order, the items ordered, and additional information such as the type, name, and price of the items. The analysis aims to uncover insights on item popularity, order values, revenue patterns, and order combinations.

## Key Questions

The following key questions were addressed in the analysis:

1. **What were the least and most ordered items? What categories were they in?**
2. **What do the highest spend orders look like? Which items did they buy and how much did they spend?**
3. **Were there certain times that had more or fewer orders?**
4. **Which cuisines should we focus on developing more menu items for based on the data?**
5. **What promotions or offers would be most effective at increasing sales?**


## Data Exploration and Cleaning

1. **Explored Tables:**
   - `order_details`
   - `menu_items`
   - `restaurant_db_data_dictionary`

2. **Renamed Columns for Clarity:** 
   Ensured the columns in the `order_details` and `menu_items` tables had consistent and clear names.

## Analysis Steps

### 1. Item Popularity Analysis

- **Most Ordered Items:** Identified the top 5 items with the highest order counts, categorized by item name and category.
- **Least Ordered Items:** Identified the 5 items with the lowest order counts, categorized by item name and category.

### 2. Order Value Analysis

- **Highest Value Orders:** Analyzed the top 10 highest spend orders, detailing the items ordered and the total amount spent.
- **Most Common Items in High-Value Orders:** Determined which items appeared most frequently in the top 25 highest value orders and calculated the revenue they generated.

### 3. Time-Based Analysis

- **Order Volumes by Time of Day:** Analyzed the number of orders and items ordered at different times of the day.
- **Revenue by Time of Day:** Assessed the revenue generated at different times of the day and calculated metrics such as average order size and average order value.
- **Order Volumes and Revenue by Day of the Week:** Analyzed the number of orders, revenue, average order size, and average order value for each day of the week.

### 4. Item and Category Revenue Analysis

- **Item-Level Revenue:** Evaluated the revenue generated by each item and its respective category.
- **Category-Level Revenue:** Assessed the revenue and average price of items within each category, highlighting the most and least profitable categories.

### 5. Data Cleaning and Backup

- **Removed Rows with NULL `item_id`:** Created a backup of the `order_details` table and removed rows where the `item_id` was NULL to ensure data integrity.

### 6. Order Frequency and Revenue Analysis

- **Order Frequency and Revenue Proportion by Item:** Analyzed the frequency of orders for each item, their proportion of total items ordered, order frequency, revenue generated, and the proportion of total revenue.

### 7. Order Combinations Analysis

- **Order Summary Table Creation:** Created a comprehensive summary table combining order details with item information.
- **Identify Items Ordered Together:** Analyzed which items were frequently ordered together.
- **Calculate Average Items per Order:** Determined the average number of items per order.

### 8. Export Preparation

- **Prepared Data for CSV Export:** Cleaned and organized the data, removing redundant columns and preparing it for easy export and analysis.

## Conclusion

This analysis provided insights into item popularity, order values, revenue patterns, and order combinations, which can inform strategic decisions for menu development and marketing efforts. The findings can help the restaurant focus on popular items, optimize pricing strategies, and improve customer satisfaction by understanding ordering patterns and preferences.
