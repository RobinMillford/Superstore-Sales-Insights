create Database SuperStore;

use SuperStore;

select * from superstore_data;

--1. percentage of total orders were shipped on the same date
SELECT 
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM superstore_data) AS percentage
FROM 
    superstore_data
WHERE 
    Order_Date = Ship_Date;


--2. Top 3 customers with highest total value of orders.
SELECT 
    TOP 3 
    Customer_Name, 
    SUM(Sales) AS Total_Sales
FROM 
    superstore_data
GROUP BY 
    Customer_Name
ORDER BY 
    Total_Sales DESC;

-- 3. The top 5 items with the highest average sales per day.
SELECT
Top 5
    Product_Name, 
    AVG(Sales) AS Avg_Sales_Per_Day
FROM 
    superstore_data
WHERE 
    Ship_Date > Order_Date
GROUP BY 
    Product_Name
ORDER BY 
    Avg_Sales_Per_Day DESC
;

-- 4. The average order value for each customer, and rank the customers by their average order value.
SELECT 
    Customer_Name, 
    AVG(Sales) AS Avg_Order_Value
FROM 
    superstore_data
GROUP BY 
    Customer_Name
ORDER BY 
    Avg_Order_Value DESC;

-- 5. the name of customers who ordered highest and lowest orders from each city.
WITH 
    CTE AS (
        SELECT 
            *,
            ROW_NUMBER() OVER (
                PARTITION BY 
                    City
                ORDER BY 
                    Sales DESC
            ) AS Row_Num_Highest,
            ROW_NUMBER() OVER (
                PARTITION BY 
                    City
                ORDER BY 
                    Sales ASC
            ) AS Row_Num_Lowest
        FROM 
            superstore_data
    )
SELECT 
    CTE.City,
    MAX(CASE WHEN CTE.Row_Num_Highest = 1 THEN CTE.Customer_Name END) AS Customer_With_Highest_Order,
    MAX(CASE WHEN CTE.Row_Num_Lowest = 1 THEN CTE.Customer_Name END) AS Customer_With_Lowest_Order
FROM 
    CTE
GROUP BY 
    CTE.City;

-- 6. The most demanded sub-category in the west region
SELECT
Top 1
    Sub_Category,
    SUM(Sales) AS Total_Sales
FROM 
    superstore_data
WHERE 
    Region = 'West'
GROUP BY 
    Sub_Category
ORDER BY 
    Total_Sales DESC;

-- 7. The highest number of items
SELECT
Top 1
    Order_ID, 
    COUNT(Product_ID) AS Number_of_Items 
FROM 
    superstore_data 
GROUP BY 
    Order_ID 
ORDER BY 
    Number_of_Items DESC;

--8. the highest cumulative value
SELECT
Top 1
    Order_ID, 
    SUM(Sales) AS Cumulative_Value 
FROM 
    superstore_data 
GROUP BY 
    Order_ID 
ORDER BY 
    Cumulative_Value DESC;

-- 9. segment’s order is more likely to be shipped via first class
SELECT 
    Segment, 
    COUNT(*) AS Total_Orders, 
    SUM(CASE WHEN Ship_Mode = 'First Class' THEN 1 ELSE 0 END) AS First_Class_Orders, 
    ROUND(SUM(CASE WHEN Ship_Mode = 'First Class' THEN 1 ELSE 0 END) * 100 / COUNT(*), 2) AS First_Class_Percentage
FROM 
    superstore_data 
GROUP BY 
    Segment;

-- 10.
SELECT
TOP 1
    City, 
    SUM(Sales) AS Total_Revenue 
FROM 
    superstore_data 
GROUP BY 
    City 
ORDER BY 
    Total_Revenue ASC ;

 --11. the average time for orders to get shipped after order is placed
SELECT 
    AVG(DATEDIFF(day, Order_Date, Ship_Date)) AS Avg_Shipping_Time 
FROM 
    superstore_data;

--12. segment places the highest number of orders from each state and which segment places the largest individual orders from each state

SELECT 
    sd.State, 
    (
        SELECT TOP 1 Segment
        FROM superstore_data sub
        WHERE sub.State = sd.State
        GROUP BY sub.State, sub.Segment
        ORDER BY COUNT(*) DESC
    ) AS Highest_Number_Of_Orders_Segment,
    (
        SELECT TOP 1 Segment
        FROM superstore_data sub
        WHERE sub.State = sd.State
        GROUP BY sub.State, sub.Segment
        ORDER BY SUM(Sales) DESC
    ) AS Largest_Individual_Orders_Segment
FROM 
    (SELECT DISTINCT State FROM superstore_data) sd;
