
-- Question:
-- Swiggy Case Study-
#################################################
-- 1. Find customers who have never ordered
USE ZOMATO;

SELECT name FROM users_7
where user_id NOT IN (SELECT user_id FROM orders);
####################################################

-- 2. Average Price/dish
SELECT f.f_name,AVG(price) FROM menu m
JOIN food f
ON f.f_id=m.f_id
GROUP BY f.f_name;

##################################################################
-- 3. Find the top restaurant in terms of the number of orders for a given month
-- for month june
SELECT r.r_name,count(o.r_id) FROM orders o
JOIN restaurants r
ON o.r_id=r.r_id
WHERE MONTHNAME(date) LIKE 'june'
GROUP BY r.r_name
ORDER BY count(o.r_id) DESC
LIMIT 1;

-- for month july

SELECT r.r_name,count(o.r_id) FROM orders o
JOIN restaurants r
ON o.r_id=r.r_id
WHERE MONTHNAME(date) LIKE 'july'
GROUP BY r.r_name
ORDER BY count(o.r_id) DESC
LIMIT 1;

-- for month may

SELECT r.r_name,count(o.r_id) FROM orders o
JOIN restaurants r
ON o.r_id=r.r_id
WHERE MONTHNAME(date) LIKE 'may'
GROUP BY r.r_name
ORDER BY count(o.r_id) DESC
LIMIT 1;

############################################################
-- 4. restaurants with monthly sales greater than x for
SELECT r.r_name,SUM(amount) As 'Revenue'FROM orders o
JOIN restaurants r
ON o.r_id=r.r_id
WHERE MONTHNAME(date) LIKE 'JUNE'
GROUP BY r.r_name
HAVING Revenue>500;

#####################################################
-- 5. Show all orders with order details for a particular customer in a particular date range


SELECT 
    u.user_id, 
    u.name, 
    COUNT(o.order_id) AS order_count 
FROM 
    users_7 AS u
JOIN 
    orders AS o ON u.user_id = o.user_id
WHERE 
    o.date > "2022-05-15" AND o.date < "2022-06-15"
GROUP BY 
    u.user_id, u.name; 

##########################################
-- 6. Find restaurants with max repeated customers

SELECT r.r_name, COUNT(*) AS loyal_customers
FROM (
    SELECT r_id, user_id, COUNT(*) AS visits
    FROM orders
    GROUP BY r_id, user_id
    HAVING visits > 1
) t
JOIN restaurants r ON r.r_id = t.r_id
GROUP BY r.r_id, r.r_name
ORDER BY loyal_customers DESC
LIMIT 1;

############################################
-- 7. Month over month revenue growth of swiggy
WITH sales AS (
    SELECT 
        MONTH(date) AS month_num, 
        MONTHNAME(date) AS month, 
        SUM(amount) AS revenue
    FROM orders
    GROUP BY month_num, month
    ORDER BY month_num
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month_num) AS prev,
    ((revenue - LAG(revenue) OVER (ORDER BY month_num)) / LAG(revenue) OVER (ORDER BY month_num)) * 100 AS growth
FROM sales;


#######################################################################
-- 8. Customer - favorite food
WITH temp AS (
    SELECT o.user_id, od.f_id, COUNT(*) AS frequency
    FROM orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.user_id, od.f_id
)

SELECT u.name,f.f_name
FROM temp t1
JOIN users u
ON u.user_id=t1.user_id
JOIN food f
ON f.f_id=t1.f_id
WHERE t1.frequency = (
    SELECT MAX(t2.frequency)
    FROM temp t2
    WHERE t2.user_id = t1.user_id
);
###########################################