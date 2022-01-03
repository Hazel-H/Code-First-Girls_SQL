
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
   


