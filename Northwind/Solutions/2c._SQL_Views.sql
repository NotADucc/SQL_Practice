/*
Definition
- A view is a saved SELECT statement
- A view can be seen as a virtual table composed of other tables & views
- No data is stored in the view itself, at each referral the underlying SELECT is re-executed;

Advantages
- Hide complexity of the database
	- Hide complex database design
	- Make large and complex queries accessible and reusable
	- Can be used as a partial solution for complex problems
- Used for securing data access: revoke access to tables and grant access to customised views. 
- Organise data for export to other applications
*/

/* Exercises */

-- Exercise 1
-- The company wants to weekly check the stock of their products.
-- If the stock is below 15, they'd like to order more to fulfill the need.

-- (1.1) Create a QUERY that shows the ProductId, ProductName and the name of the supplier, do not forget the WHERE clause.
SELECT p.ProductID, p.ProductName, s.CompanyName
FROM Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE p.UnitsInStock < 15 AND Discontinued = 0

-- (1.2) Turn this SELECT statement into a VIEW called: vw_products_to_order.
CREATE VIEW vw_products_to_order(ProductId, ProductName, SupplierName) AS
SELECT p.ProductID, p.ProductName, s.CompanyName
FROM Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE p.UnitsInStock < 15 AND Discontinued = 0

-- (1.3) Query the VIEW to see the results.
SELECT * 
FROM vw_products_to_order

-- (1.4) We've noticed an changes in consumer behavior and would like to change the 15 threshold to 20
ALTER VIEW vw_products_to_order(ProductId, ProductName, SupplierName) AS
SELECT p.ProductID, p.ProductName, s.CompanyName
FROM Products p
JOIN Suppliers s ON p.SupplierID = s.SupplierID
WHERE p.UnitsInStock < 20 AND Discontinued = 0


-- Exercise 2
-- The company has to increase prices of certain products. 
-- To make it seem the prices are not increasing dramatically they're planning to spread the price increase over multiple years. 
-- In total they'd like a 10% increase for certain products. The list of impacted products can grow over the coming years. 
-- We'd like to keep all the logic of selecting the correct products in 1 SQL View, in programming terms 'keeping it DRY'. 
-- The updating of the items is not part of the view itself.
-- The products in scope are all the products with the term 'Bröd' or 'Biscuit'.

-- (2.1) Create a simple SQL Query to get the correct resultset
SELECT 
p.ProductID, 
p.ProductName,
p.UnitPrice AS CurrentPrice,
UpdatedPrice = CASE WHEN p.ProductName LIKE '%Bröd%' OR p.ProductName LIKE '%Biscuit%' THEN p.UnitPrice * 1.1 ELSE p.UnitPrice END
FROM Products p
WHERE p.Discontinued = 0

--OR

SELECT 
p.ProductID, 
p.ProductName,
p.UnitPrice AS CurrentPrice,
UpdatedPrice = p.UnitPrice * 1.1
FROM Products p
WHERE (p.ProductName LIKE '%Bröd%' OR p.ProductName LIKE '%Biscuit%') AND p.Discontinued = 0

-- (2.2) Turn this SELECT statement into a VIEW called: vw_price_increasing_products.
CREATE VIEW vw_price_increasing_products AS
SELECT 
p.ProductID, 
p.ProductName,
p.UnitPrice AS CurrentPrice,
UpdatedPrice = CASE WHEN p.ProductName LIKE '%Bröd%' OR p.ProductName LIKE '%Biscuit%' THEN p.UnitPrice * 1.1 ELSE p.UnitPrice END
FROM Products p
WHERE p.Discontinued = 0

--OR

CREATE VIEW vw_price_increasing_products AS
SELECT 
p.ProductID, 
p.ProductName,
p.UnitPrice AS CurrentPrice,
UpdatedPrice = p.UnitPrice * 1.1
FROM Products p
WHERE (p.ProductName LIKE '%Bröd%' OR p.ProductName LIKE '%Biscuit%') AND p.Discontinued = 0

-- (2.3) Query the VIEW to see the results.
SELECT *
FROM vw_price_increasing_products

-- (2.4) There was enormous backlash at the price increase, the view is not needed anymore.
DROP VIEW vw_price_increasing_products