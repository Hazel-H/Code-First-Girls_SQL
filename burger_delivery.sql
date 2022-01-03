-- creating a database 

CREATE DATABASE PROJECT;

USE PROJECT;

CREATE TABLE customers(
customer_id int NOT NULL,
first_name VARCHAR(20),
last_name VARCHAR(20),
address VARCHAR(50) NOT NULL, 
PRIMARY KEY (customer_id)
);

INSERT INTO customers
(customer_id, first_name, last_name, address) 
VALUES
(1231, 'Hazel', 'Hallett', 'Bath'),
(1232, 'Charlotte', 'Gregory', 'Bristol'),
(1233, 'Harry', 'Brown', 'Bath'), 
(1234, 'Hannah', 'Nicol', 'Glastonbury'), 
(1235, 'Sankhya', 'Ramanan', 'Bristol'), 
(1236, 'Holly', 'Baines', 'Chippenham'), 
(1237, 'John', 'Smith', 'Bristol'), 
(1238, 'Tom', 'Booth', 'Bath'); 



CREATE TABLE ingredients(
food  VARCHAR(20), 
ingredients1 VARCHAR(20), 
ingredients2 VARCHAR(20), 
ingredients3 VARCHAR(20), 
PRIMARY KEY (food)
);

INSERT INTO ingredients 
(food, ingredients1, ingredients2, ingredients3) 
VALUES
('burger', 'bun', 'beef patty', 'salad'), 
('chips', 'potatoes', null, null),  
('chicken_burger', 'bun', 'beef patty', 'salad'), 
('veg_burger', 'bun', 'beef patty', 'salad'); 


CREATE TABLE order_items(
order_id int NOT NULL,
food  VARCHAR(20) NOT NULL, 
price FLOAT(2), 
FOREIGN KEY (food) REFERENCES ingredients(food) 
);

INSERT INTO order_items 
(order_id, food, price) 
VALUES
(1111, 'burger', 10.50),  
(1111, 'chips', 6.20),  
(1112, 'chicken_burger', 12.99),  
(1113, 'veg_burger', 9.99),  
(1113, 'veg_burger', 9.99),  
(1114, 'veg_burger', 9.99),  
(1114, 'chicken_burger', 12.99),  
(1115, 'chips', 6.20),    
(1115, 'chicken_burger', 12.99),  
(1115, 'chicken_burger', 12.99),  
(1115, 'chips', 6.20),    
(1116, 'burger', 10.50),  
(1117, 'chicken_burger', 12.99),  
(1118, 'veg_burger', 9.99),  
(1118, 'veg_burger', 9.99),  
(1119, 'chips', 6.20),  
(1119, 'burger', 10.50); 


CREATE TABLE delivery_status(
order_id int NOT NULL,
delivery_status boolean,
delivery_time timestamp, 
PRIMARY KEY (order_id)
);

INSERT INTO delivery_status
(order_id, delivery_status, delivery_time) 
VALUES
(1111, True, '2021-11-24 18:30:00'),  
(1112, False, null),  
(1113, False, null),  
(1114, False, null),  
(1115, False, null),  
(1116, True, '2021-11-24 19:05:00'),  
(1117, True, '2021-11-24 18:57:00'),  
(1118, True, '2021-11-24 19:30:00'),  
(1119, False, null);  

CREATE TABLE orders(
order_id int NOT NULL,
customer_id int NOT NULL,
restaurant_id VARCHAR(20) NOT NULL, 
total_price FLOAT(2),  
discount FLOAT(2),
order_time TIMESTAMP,   
PRIMARY KEY (order_id), 
FOREIGN KEY (customer_id) REFERENCES customers(customer_id), 
FOREIGN KEY (order_id) REFERENCES delivery_status(order_id)
);


INSERT INTO orders
(order_id, customer_id, restaurant_id, total_price, discount, order_time) 
VALUES
(1111, 1231, 'Bath', 21.50, null, '2021-11-24 18:00:00'),  
(1112, 1238, 'Bath', 10.99, null, '2021-11-24 19:30:00'),  
(1113, 1237, 'Bath', 30.21, null, '2021-11-24 19:15:00'),  
(1114, 1236, 'Bath', 64.11, null, '2021-11-24 19:57:00'),  
(1115, 1235, 'Bristol', 71.00, 25, '2021-11-24 20:30:00'),  
(1116, 1234, 'Bristol', 11.20, 50, '2021-11-24 18:30:00'),  
(1117, 1233, 'Bristol', 9.80, null, '2021-11-24 18:10:00'),  
(1118, 1232, 'Bristol', 45.90, 10, '2021-11-24 18:30:00'),  
(1119, 1232, 'Bath', 29.80, null, '2021-11-24 21:30:00');  


-- TOTAL PRICE OF ORDERS BY LOCATION WHERE LOCATION MUST BE BATH OR BRISTOL 
SELECT  
   SUM(orders.total_price), customers.address  
FROM 
   orders 
JOIN 
   customers on customers.customer_id = orders.customer_id
GROUP BY
   customers.address 
HAVING customers.address = 'Bristol' OR customers.address = 'Bath';

-- FUNCTION TO CALCULATE AMENDED PRICE TAKING INTO ACCOUNT THE DISCOUNT 
DELIMITER //
CREATE FUNCTION apply_discount(
    discount FLOAT, total_price FLOAT 
) 
RETURNS FLOAT(2)
DETERMINISTIC
BEGIN
    DECLARE updated_price FLOAT;
    IF discount = null THEN
        SET updated_price = total_price;
    ELSE
        SET updated_price = total_price * (1-(discount/100));
    END IF;
    RETURN (updated_price);
END//
DELIMITER ;

-- APPLY AND TEST FUNCTION 
SELECT 
    total_price, discount, apply_discount(discount, total_price) AS new_price
FROM
    orders;
    
-- CREATE A SUB QUERY WITHIN QUERY TO SHOW ID AND PRICE FOR ALL ORDERS THAT CONTAIN A CHICKEN BURGER 
SELECT 
   order_id, total_price 
FROM 
   orders 
WHERE order_id in
  (SELECT order_id 
  FROM order_items 
  WHERE order_items.food = 'chicken_burger'); 
  
  -- CREATE VIEW 
CREATE VIEW ingredient_breakdown
AS 
SELECT o.order_id, oi.food, i.ingredients1, i.ingredients2, i.ingredients3
FROM orders o
   INNER JOIN
   order_items oi
   ON oi.order_id = o.order_id
   INNER JOIN
   ingredients AS i
   ON i.food = oi.food; 

select * from ingredient_breakdown; 

-- CREATE STORED PROCEDURE -- ADDING NEW FOOD ITEM TO THE MENU 
DELIMITER //
CREATE PROCEDURE UpdateMenu(
IN food VARCHAR(20),
IN ingredients1 VARCHAR(20),
IN ingredients2 VARCHAR(20),
IN ingredients3 VARCHAR(20))
BEGIN
INSERT INTO ingredients(food,ingredients1, ingredients2, ingredients3)
VALUES (food,ingredients1, ingredients2, ingredients3);
END//
DELIMITER ;

-- DEMONSTRATE ABOVE STORED PROCEDURE
CALL UpdateMenu ('milkshake', 'milk', 'ice_cream', null);
SELECT *
FROM ingredients;


-- TIME TAKEN FOR EACH ORDER THAT HAS BEEN DELIVERED
SELECT    o.order_id, timestampdiff(MINUTE, o.order_time, ds.delivery_time) AS delivery_time_minutes
FROM 
   orders o 
JOIN 
   delivery_status ds ON ds.order_id = o.order_id
WHERE 
   ds.delivery_status = True; 
   

