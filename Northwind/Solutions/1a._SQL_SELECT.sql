-- 1. Show all data of all products	
SELECT *
FROM Products

-- 2. Show for all a products productID, name and unitprice
SELECT productid, productname, unitprice
FROM Products

-- 3. Show productid, productname and unitprice of all products from category 1
SELECT productid, productname, unitprice
FROM Products
WHERE categoryID = 1

-- 4. Show productID, name, units in stock for all products with less than 5 units in stock
SELECT productid, productname, unitprice
FROM Products
WHERE UnitsInStock < 5

-- 5. Show productID, name, units in stock for all products for which the name starts with A
SELECT productid, productname, unitprice
FROM Products
WHERE productname >= 'A' AND productname < 'B'

-- Wildcards (searching for patterns)
-- Always in combination with operator LIKE, NOT LIKE
-- Wildcard symbols:
-- % -> arbitrary sequence of 0, 1  or more characters
-- _  -> 1 character
-- [ ]  -> 1 character in a specified range
-- [^] -> every character not in the specified range

-- 6. Show productID and name of the products for which the second letter is in the range a-k
SELECT productid, productname
FROM Products
WHERE productname LIKE '_[a-k]%'

-- 7. Show productid, productname, supplierid and unitPrice for all products for which the name starts with T 
-- or has the productid = 46 with a unitprice higher than 16
-- Hint(OR, AND, NOT)
SELECT ProductID, ProductName, SupplierID, UnitPrice
FROM Products
WHERE ProductName LIKE 'T%' OR (ProductID = 46 AND UnitPrice > 16.00)

-- 8. Select the products (name and unit price) for which the unit price is between 10 and 15 euro (boundaries included)
--Hint (BETWEEN, NOT BETWEEN)
SELECT ProductName, UnitPrice
FROM Products
WHERE UnitPrice BETWEEN 10 AND 15

-- 9. Show ProductID, ProductName and SupplierID of the products supplied by suppliers with ID 1, 3 or 5
-- Hint(IN, NOT IN)
SELECT ProductID, ProductName, SupplierID
FROM Products
WHERE SupplierID in (1,3,5)

-- IS NULL,  IS NOT NULL
-- * NULL values occur if no value has been specified for a column when creating a record
-- * A NULL is not equal to 0 (for numerical values), blank or empty string (for character values)!
-- * NULL fields are considered as equal (for e.g. testing with DISTINCT)
-- * If a NULL value appears in an expression the result is always NULL

-- 10. Select suppliers from an unknown region
-- Hint(IS NULL,  IS NOT NULL)
SELECT CompanyName, Region
FROM Suppliers
WHERE Region IS NULL

-- 11. Select suppliers different from Oregon (OR)
SELECT CompanyName, Region
FROM Suppliers
WHERE Region <> 'OR' OR Region IS NULL

-- 12. Show an alphabetic list of product names
-- Hint(ORDER BY)
SELECT ProductName
FROM Products
ORDER BY ProductName

--OR

SELECT ProductName
FROM Products
ORDER BY 1


-- 13. Show productid, name, categoryID of the products sorted by categoryID. 
-- If the category is the same products with the highest price appear first.
SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM Products
ORDER BY CategoryID, UnitPrice DESC

-- DISTINCT / ALL
-- DISTINCT filters out duplicates lines in the output
-- ALL (default) shows all rows, including duplicates

-- 14. Show all suppliers that supply products
-- Hint(DISTINCT / ALL)
SELECT SupplierID
FROM Products
ORDER BY SupplierID 

-- 15. Show all suppliers that supply products no duplicate suppliers allowed
-- Hint(DISTINCT / ALL)
SELECT DISTINCT SupplierID
FROM Products
ORDER BY SupplierID 


-- 16. Select ProductID, ProductName of the products.
-- but id like ProductID shown as ProductNummer and ProductName shown as Name Product
-- Hint(Aliases)
SELECT ProductID AS ProductNummer, ProductName AS 'Name Product'
FROM Products

--OR

SELECT ProductID ProductNummer, ProductName 'Name Product'
FROM Products

-- 17. Give name and inventory value of the products
-- Hint(Arithmetic operators : +, -, /, *)
SELECT ProductName, UnitPrice * UnitsInStock  AS InventoryValue
FROM Products

-- ISNULL: replaces NULL values with specified value
-- 18. Give CompanyName and Region of Suppliers
-- If region is not known show Unknown
SELECT CompanyName, Region, ISNULL(Region, 'Unknown')
FROM Suppliers 
 
