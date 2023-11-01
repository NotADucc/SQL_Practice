-- 1. Count the amount of products (columnname 'Amount of Products'), AND the amount of products in stock (columnname 'Units in Stock') 
SELECT COUNT(*) AS 'Amount of Products', SUM(UnitsInStock) AS 'Units in Stock'
FROM Products


-- 2. How many employees have a function of Sales Representative (columnname 'Number of Sales Representative')? 
SELECT COUNT(*) AS 'Number of Sales Representative'
FROM Employees
WHERE Title LIKE 'Sales Representative'


-- 3. Give the date of birth of the youngest employee (columnname 'Birthdate youngest') and the eldest (columnname 'Birthdate eldest').
SELECT MAX(BirthDate) AS 'Birthdate youngest', MIN(BirthDate) AS 'Birthdate eldest'
FROM Employees

-- 4. What's the number of employees who will retire (at 65) within the first 20 years? 
SELECT COUNT(*)
FROM Employees
WHERE YEAR(GETDATE()) + 20 - YEAR(BirthDate) >= 65

-- 5. Show a list of different countries where 2 of more suppliers are from. Order alphabeticaly. 
SELECT Country, COUNT(*)
FROM Suppliers
GROUP BY Country
HAVING COUNT(*) >= 2
ORDER BY Country


-- 6. Which suppliers offer at least 5 products with a price less than 100 dollar? Show supplierId and the number of different products. 
-- The supplier with the highest number of products comes first. 
SELECT SupplierID, COUNT(*)
FROM Products
WHERE UnitPrice < 100
GROUP BY SupplierID
HAVING COUNT(*) >= 5
ORDER BY COUNT(*)