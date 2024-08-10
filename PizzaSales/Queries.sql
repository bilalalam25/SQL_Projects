-- 1. Retrieve the total number of orders placed.

SELECT COUNT(order_id) as total_orders FROM orders;

-- 2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id;
    
-- 3. Identify the highest-priced pizza.

SELECT MAX(price) FROM pizzas;

SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.
SELECT 
    pizzas.size, COUNT(order_details.quantity) AS quantity_order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY quantity_order_count DESC
LIMIT 1;

-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY quantity DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

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
ORDER BY total_quantity DESC
LIMIT 5;

-- 7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hour, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hour
ORDER BY hour ASC;

-- 8. Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name) AS distribution
FROM
    pizza_types
GROUP BY category
ORDER BY distribution ASC;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT order_date,
    ROUND(AVG(total_quantity),0) AS AVG_pizza
FROM
    (SELECT 
        orders.order_date,
            SUM(order_details.quantity) AS total_quantity
    FROM
        order_details
    JOIN orders ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date)total
GROUP BY 
order_date;

-- 10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    order_details.pizza_id AS pizza_type,
    ROUND(SUM(order_details.quantity*pizzas.price),2) AS revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_type
ORDER BY revenue DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizzas.pizza_type_id,
    CONCAT(ROUND(((SUM(order_details.quantity * pizzas.price)) / (SELECT 
                            SUM(pizzas.price)
                        FROM
                            pizzas
                                JOIN
                            order_details ON order_details.pizza_id = pizzas.pizza_id)) * 100,
                    2),
            '%') AS total_revenue
FROM
    order_details
        JOIN
    pizzas ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizzas.pizza_type_id
ORDER BY pizzas.pizza_type_id;

-- 12. Analyze the cumulative revenue generated over time.

select order_date,
round(sum(revenue) over (order by order_date),2) as cum_revenue
from 
(select orders.order_date,
sum(order_details.quantity*pizzas.price) as revenue
from order_details join pizzas on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by orders.order_date) as sales;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name, revenue from 
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn<=3;