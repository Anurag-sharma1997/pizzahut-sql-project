# Pizzahut Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
  
**Database**: `pizzahut`


## Objectives

**This project aims to analyze pizza sales data to derive meaningful business insights. The analysis is divided into Basic, Intermediate, and Advanced levels, providing a structured approach to understanding sales trends, customer preferences, and revenue distribution.**

## Project Structure

### 1. Database Setup

**Database Creation**: The project starts by creating a database named `pizzahut`.

**Table Creation**

```sql

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

```

### 2. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Retrieve the total number of orders placed.**:
```sql
SELECT 
    COUNT(order_id) AS total_orders
FROM
    orders;
```


2. **Calculate the total revenue generated from pizza sales.**:
```sql
SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id;
```

3. **Identify the highest-priced pizza.**:
```sql
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;
```


4. **Identify the most common pizza size ordered.**:
```sql
SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS pizzas_ordered
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY pizzas_ordered DESC;
```

5. **List the top 5 most ordered pizza types along with their quantities.**:
```sql
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
```

6. **Join the necessary tables to find the total quantity of each pizza category ordered.**:
```sql
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
```


7. **Determine the distribution of orders by hour of the day.**:
```sql
SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS orders
FROM
    orders
GROUP BY HOUR(order_time);
```


8. **join relevant tables to find the category-wise distribution of pizzas.**:
```sql
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;
```


9. **Group the orders by date and calculate the average number of pizzas ordered per day.**:
```sql
SELECT 
    ROUND(AVG(quantity), 0) AS avg_order_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS order_quantity;
```

10. **Determine the top 3 most ordered pizza types based on revenue.**:
```sql
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

```

11. **Calculate the percentage contribution of each pizza type to total revenue.**:
```sql
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
```

12. **Calculate the percentage contribution of each pizza to total revenue.**:
```sql
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

```


13. **Calculate the percentage contribution of each pizza category to total revenue.**:
```sql
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
```




14. **Analyze the cumulative revenue generated over time.**:
```sql
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

```


15. **Determine the top 3 most ordered pizza types based on revenue for each pizza category.**:
```sql
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
```


## Business Recommendations

 - **Promote Best-Selling Pizzas **: Run special offers on the top 5 pizzas to maximize revenue.
- **Optimize Pricing **: The highest-priced pizza sells less frequently; consider bundling it with deals.
- **Inventory Management **: Medium-sized pizzas are the most ordered; ensure sufficient stock.
- ** Staff Scheduling **: Peak hours (lunch & dinner) require more kitchen staff.
- **Category-Based Promotions **: If one category sells more, adjust marketing focus accordingly.
- **Seasonal Campaigns **: Revenue fluctuates over time; plan seasonal offers strategically.


## Conclusion

This analysis provides critical business insights to optimize pizza sales strategy.
✅ High-revenue pizzas should be promoted aggressively.
✅ Peak order times should be leveraged with marketing and staffing adjustments.
✅ Customer preferences (pizza size, category, bestsellers) should guide menu decisions.
✅ Revenue tracking and seasonal trends should inform future sales strategies.

























































































