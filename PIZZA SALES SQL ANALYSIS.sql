### 1. Database Setup

create database pizzahut;
SELECT * FROM pizzahut.pizzas;

-- **Table Creation**

CREATE TABLE orders (
    order_id INT NOT NULL PRIMARY KEY,
    order_date DATE NOT NULL,
    order_time TIME NOT NULL
);

CREATE TABLE order_details (
    order_details_id int not null primary key,
	order_id int not null,
	pizza_id text not null,
	quantity int not null
);

========================== -- Retrieve the total number of orders placed.

SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
    
 -- Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
    
   --  Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza size ordered.

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS pizzas_ordered
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY pizzas_ordered DESC;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity) AS most_ordered
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY most_ordered DESC
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS total_quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY total_quantity DESC;

-- Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS orders
FROM
    orders
GROUP BY HOUR(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.


SELECT 
    ROUND(AVG(quantity), 0) AS avg_order_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
    
-- Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS total_revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_revenue DESC
LIMIT 3;

-- Calculate the percentage contribution of each pizza type to total revenue.

WITH PizzaRevenue AS (
    SELECT 
        pizza_types.name AS pizza_name,
        SUM(order_details.quantity * pizzas.price) AS total_revenue
    FROM
        pizza_types
        JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.name
), 
TotalRevenue AS (
    SELECT SUM(total_revenue) AS overall_revenue FROM PizzaRevenue
)
-- Calculate the percentage contribution of each pizza to total revenue.
WITH PizzaRevenue AS (
    SELECT 
        pizza_types.name AS pizza_name,
        SUM(order_details.quantity * pizzas.price) AS total_revenue
    FROM
        pizza_types
        JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.name
), 
TotalRevenue AS (
    SELECT SUM(total_revenue) AS overall_revenue FROM PizzaRevenue
)

SELECT 
    pr.pizza_name,
    pr.total_revenue,
    ROUND((pr.total_revenue / tr.overall_revenue) * 100, 2) AS percentage_contribution
FROM 
    PizzaRevenue pr
    JOIN TotalRevenue tr ON 1=1
ORDER BY pr.total_revenue DESC;





-- Calculate the percentage contribution of each pizza category to total revenue.
SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_sale
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


Analyze the cumulative revenue generated over time.


SELECT order_date, 
SUM(revenue) 
OVER(ORDER BY  order_date) AS cum_revenue 
FROM
		( SELECT orders.order_date,
		SUM(order_details.quantity * pizzas.price) AS revenue
		FROM
        order_details JOIN pizzas
		ON order_details.pizza_id = pizzas.pizza_id 
        JOIN orders
		ON orders.order_id = order_details.order_id
		GROUP BY orders.order_date ) AS sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.



SELECT category, name, revenue  FROM
(SELECT 
    category, 
    name, 
    revenue,
    RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rn
FROM (
    SELECT 
        pizza_types.category,
        pizza_types.name,
        SUM(order_details.quantity * pizzas.price) AS revenue
    FROM pizza_types
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name
) AS ranked_pizzas) as b WHERE rn <= 3;


-- END=======================================================================================================================================================




