/************************/
/******* Cursors ********/
/************************/

/*
SQL statements are processing complete resultsets and not individual rows. 
Cursors allow to process individual rows to perform complex row specific 
operations that can't (easily) be performed with a single SELECT, UPDATE or DELETE statement.
A cursor is a database object that refers to the result of a query. 
It allows to specify the row from the resultset you wish to process.

A cursor is a database object that refers to the result of a query. 
It allows to specify the row from the resultset you wish to process.

5 important cursor related statements
- DECLARE CURSOR – creates and defines the cursor
- OPEN – opens the declared cursor
- FETCH – fetches 1 row
- CLOSE – closes the cursor (counterpart of OPEN)
- DEALLOCATE – remove the cursor definition (counterpart of DECLARE)


*/


DECLARE @supplierID INT, @companyName NVARCHAR(30), @city NVARCHAR(15)

-- declare cursor
DECLARE suppliers_cursor CURSOR 
FOR
SELECT SupplierID, CompanyName, City
FROM Suppliers
WHERE Country = 'USA'

-- open cursor
OPEN suppliers_cursor

-- fetch data
FETCH NEXT FROM suppliers_cursor INTO @supplierID, @companyName, @city

WHILE @@FETCH_STATUS = 0 
BEGIN 
	PRINT 'Supplier: ' + str(@SupplierID) + ' ' + @companyName + ' ' + @city
  	FETCH NEXT FROM suppliers_cursor INTO @supplierID, @companyName, @city
END 

-- close cursor
CLOSE suppliers_cursor

-- deallocate cursor
DEALLOCATE suppliers_cursor
GO;

-- Exercise
-- Give an overview of all contactNames in Suppliers 
-- that are some kind of manager

/*
- Exotic Liquids > Charlotte Cooper > Purchasing Manager
- Tokyo Traders > Yoshi Nagase > Marketing Manager
- Pavlova, Ltd. > Ian Devling > Marketing Manager
- Refrescos Americanas LTDA > Carlos Diaz > Marketing Manager
- Heli Süßwaren GmbH & Co. KG > Petra Winkler > Sales Manager
- Norske Meierier > Beate Vileid > Marketing Manager
- Aux joyeux ecclésiastiques > Guylène Nodier > Sales Manager
- Lyngbysild > Niels Petersen > Sales Manager
- Zaanse Snoepfabriek > Dirk Luchte > Accounting Manager
...
*/

DECLARE @companyName NVARCHAR(40), @contactName NVARCHAR(30), @contactTitle NVARCHAR(30);

-- declare cursor
DECLARE suppliers_cursor CURSOR 
FOR
SELECT CompanyName, ContactName, ContactTitle
FROM Suppliers
WHERE ContactTitle LIKE '%Manager%'

-- open cursor
OPEN suppliers_cursor

-- fetch data
FETCH NEXT FROM suppliers_cursor INTO @companyName, @contactName, @contactTitle

WHILE @@FETCH_STATUS = 0 
BEGIN 
	PRINT @companyName + ' > ' + @contactName + ' > ' + @contactTitle
  	FETCH NEXT FROM suppliers_cursor INTO @companyName, @contactName, @contactTitle
END 

-- close cursor
CLOSE suppliers_cursor

-- deallocate cursor
DEALLOCATE suppliers_cursor
GO;

/************************/
/****  Nested cursors  **/
/************************/

DECLARE @supplierID INT, @companyName NVARCHAR(30), @city NVARCHAR(15)
DECLARE @productID INT, @productName NVARCHAR(40), @unitPrice MONEY

-- declare cursor
DECLARE suppliers_cursor CURSOR 
FOR
SELECT SupplierID, CompanyName, City
FROM Suppliers
WHERE Country = 'USA'

-- open cursor
OPEN suppliers_cursor

-- fetch data
FETCH NEXT FROM suppliers_cursor INTO @supplierID, @companyName, @city

WHILE @@FETCH_STATUS = 0 
BEGIN 
	PRINT 'Supplier: ' + str(@SupplierID) + ' ' + @companyName + ' ' + @city
	--  begin inner cursor
	DECLARE products_cursor CURSOR 	FOR
	SELECT ProductID, ProductName, UnitPrice FROM Products WHERE SupplierID = @supplierID

	-- open cursor
	OPEN products_cursor

	-- fetch data
	FETCH NEXT FROM products_cursor INTO @productID, @productName, @unitPrice

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		PRINT '- ' + STR(@productID) + ' ' + @productName + ' ' + STR(@unitPrice) + 'EUR'
		FETCH NEXT FROM products_cursor INTO @productID, @productName, @unitPrice
	END

	CLOSE products_cursor

	-- deallocate cursor
	DEALLOCATE products_cursor

	-- end inner cursor
  	FETCH NEXT FROM suppliers_cursor INTO @supplierID, @companyName, @city
END 

-- close cursor
CLOSE suppliers_cursor

-- deallocate cursor
DEALLOCATE suppliers_cursor
GO;

/************************/
/** Cursor for update  **/
/************************/

BEGIN TRANSACTION
SELECT count(shipperID) FROM Shippers

DECLARE @shipperID INT, @companyName NVARCHAR(40)

-- declare cursor
DECLARE shippers_cursor CURSOR FOR
SELECT ShipperID, CompanyName FROM Shippers

-- open cursor
OPEN shippers_cursor

-- fetch data
FETCH NEXT FROM shippers_cursor INTO @shipperID, @companyName

WHILE @@FETCH_STATUS = 0 
BEGIN
	PRINT '- ' + STR(@shipperID) + ' ' + @companyName
	IF @shipperID > 4
		DELETE FROM Shippers WHERE CURRENT OF shippers_cursor

	FETCH NEXT FROM shippers_cursor INTO @shipperID, @companyName
END

CLOSE shippers_cursor
DEALLOCATE shippers_cursor


SELECT count(shipperID) FROM Shippers
ROLLBACK
GO;
/*************************/
/********Exercises *******/
/*************************/

-- Exercise 1
-- Create the following overview of the number of products per category
/**
Category:          1 Beverages -->         13
Category:          2 Condiments -->         13
Category:          3 Confections -->         13
Category:          4 Dairy Products -->         10
Category:          5 Grains/Cereals -->          7
Category:          6 Meat/Poultry -->          6
Category:          7 Produce -->          5
Category:          8 Seafood -->         12
**/

DECLARE @id INT, @categoryName NVARCHAR(15), @totalCount INT;

-- declare cursor
DECLARE category_cursor CURSOR 
FOR
SELECT c.CategoryID, c.CategoryName, COUNT(c.CategoryID) totalCount 
FROM Categories c
JOIN Products p ON c.CategoryId = p.CategoryID
GROUP BY c.CategoryID, c.CategoryName
-- open cursor
OPEN category_cursor

-- fetch data
FETCH NEXT FROM category_cursor INTO @id, @categoryName, @totalCount

WHILE @@FETCH_STATUS = 0 
BEGIN 
	PRINT 'Category: ' + STR(@id) + ' ' + @categoryName + ' ' + STR(@totalCount) 
  	FETCH NEXT FROM category_cursor INTO @id, @categoryName, @totalCount
END 

-- close cursor
CLOSE category_cursor

-- deallocate cursor
DEALLOCATE category_cursor

GO;

-- Exercise 2
-- Give an overview of the employees per country. Use a nested cursor.
/*

* UK
    -          5 Steven Buchanan London
    -          6 Michael Suyama London
    -          7 Robert King London
    -          9 Anne Dodsworth London
* USA
    -          1 Nancy Davolio Seattle
    -          2 Andrew Fuller Tacoma
    -          3 Janet Leverling Kirkland
    -          4 Margaret Peacock Redmond
    -          8 Laura Callahan Seattle
*/

DECLARE @country NVARCHAR(15);
DECLARE @employeeId INT, @lname NVARCHAR(20), @fname NVARCHAR(10), @city NVARCHAR(15);

-- declare cursor
DECLARE country_cursor CURSOR 
FOR
SELECT Country
FROM Employees
GROUP BY Country

-- open cursor
OPEN country_cursor 

-- fetch data
FETCH NEXT FROM country_cursor INTO @country

WHILE @@FETCH_STATUS = 0 
BEGIN 
	PRINT '* ' + @country
	--  begin inner cursor
	DECLARE employee_cursor CURSOR 	FOR
	SELECT EmployeeID, LastName, FirstName, City FROM Employees WHERE Country = @country

	-- open cursor
	OPEN employee_cursor

	-- fetch data
	FETCH NEXT FROM employee_cursor INTO @employeeId, @lname, @fname, @city

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		PRINT '- ' + STR(@employeeId) + ' ' + @fname + ' ' + @lname + ' ' + @city
		FETCH NEXT FROM employee_cursor INTO @employeeId, @lname, @fname, @city
	END

	CLOSE employee_cursor

	-- deallocate cursor
	DEALLOCATE employee_cursor

	-- end inner cursor
  	FETCH NEXT FROM country_cursor INTO @country
END 

-- close cursor
CLOSE country_cursor

-- deallocate cursor
DEALLOCATE country_cursor
GO;


-- Exercise 3
/*
Create an overview of bosses and employees who have
to report to this boss and 
also give the number of employees who have to report to this boss.
Use a nested cursor.

* Andrew Fuller
    -          1 Nancy Davolio
    -          3 Janet Leverling
    -          4 Margaret Peacock
    -          5 Steven Buchanan
    -          8 Laura Callahan
Total number of employees =          5
* Steven Buchanan
    -          6 Michael Suyama
    -          7 Robert King
    -          9 Anne Dodsworth
Total number of employees =          3
*/

DECLARE @bossName NVARCHAR(35), @bossId INT;
DECLARE @employeeId INT, @lname NVARCHAR(20), @fname NVARCHAR(10);

-- declare cursor
DECLARE boss_cursor CURSOR 
FOR
SELECT CONCAT(FirstName, ' ', LastName) boss_name, EmployeeID
FROM Employees
WHERE EmployeeID IN (SELECT ReportsTo FROM Employees)

-- open cursor
OPEN boss_cursor

-- fetch data
FETCH NEXT FROM boss_cursor INTO @bossName, @bossId

WHILE @@FETCH_STATUS = 0 
BEGIN 
	DECLARE @employeeCount INT = 0;
	PRINT '* ' + @bossName
	--  begin inner cursor
	DECLARE employee_cursor CURSOR 	FOR
	SELECT EmployeeID, LastName, FirstName FROM Employees WHERE ReportsTo = @bossId

	-- open cursor
	OPEN employee_cursor

	-- fetch data
	FETCH NEXT FROM employee_cursor INTO @employeeId, @lname, @fname

	WHILE @@FETCH_STATUS = 0 
	BEGIN
		PRINT '- ' + STR(@employeeId) + ' ' + @fname + ' ' + @lname
		FETCH NEXT FROM employee_cursor INTO @employeeId, @lname, @fname
		SET @employeeCount = @employeeCount + 1; 
	END
	PRINT 'Total number of employees = ' + STR(@employeeCount)
	CLOSE employee_cursor

	-- deallocate cursor
	DEALLOCATE employee_cursor

	-- end inner cursor
  	FETCH NEXT FROM boss_cursor INTO @bossName, @bossId
END 

-- close cursor
CLOSE boss_cursor

-- deallocate cursor
DEALLOCATE boss_cursor