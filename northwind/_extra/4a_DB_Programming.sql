/****************************/
/** Stored procedures      **/
/****************************/


/* Introduction
a stored procedure is a named collection of SQL and control-of-flow commands (program) that is stored as a database object
- Analogous to procedures/functions/methods in other languages
- Can be called from a program, trigger or stored procedure
- Is saved in the catalogue
- Accepts input and output parameters
- Returns status information about the correct or incorrect execution of the stored procedure
- Contains the tasks to be executed
*/

/* Local variables */
DECLARE @maxQuantity SMALLINT, @maxUnitPrice MONEY, @minUnitPrice MONEY
SET @maxQuantity = (SELECT MAX(quantity) FROM OrderDetails)
SELECT @maxQuantity = MAX(quantity) FROM OrderDetails
SELECT @maxUnitPrice = MAX(UnitPrice), @minUnitPrice = MIN(UnitPrice) FROM Products

/* Control flow with Transact SQL*/
CREATE PROCEDURE ShowFirstXEmployees @x INT, @missed INT OUTPUT
AS
DECLARE @empid INT, @fullname VARCHAR(100), @city NVARCHAR(30), @total int

SET @empid = 1
SELECT @total = COUNT(*) FROM Employees
-- SET @total = (SELECT COUNT(*) FROM Employees)
SET @missed = 10

IF @x > @total
 SELECT @x = COUNT(*) FROM Employees
ELSE
 SET @missed = @total - @x

WHILE @empid <= @x
BEGIN
	SELECT @fullname = firstname + ' ' + lastname, @city = city FROM Employees WHERE employeeid = @empid
	PRINT 'Full Name : ' + @fullname
	PRINT 'City : '+ @city
	PRINT '-----------------------'
	SET @empid = @empid + 1
END


-- Testcode
DECLARE @numberOfMissedEmployees INT
SET @numberOfMissedEmployees = 0
EXEC ShowFirstXEmployees 5, @numberOfMissedEmployees OUT -- don't forget OUT
PRINT 'Number of missed employees: ' + STR(@numberOfMissedEmployees)


-- Exercise
-- Write a SP DetailsCategory that gives for a given categoryID 
-- (*) the name of this category
-- (*) the number of products in this category --> use SELECT
-- (*) the average price of this category --> use SET
-- The default value for categoryID is 1
-- If there is no category with this categoryID, write an errror message: This category doesn't exist
-- Write Testcode for categoryID = 5 / 10
/*
CategoryName = Grains/Cereals
Number of products =          7
Average Unit price =         20
*/









-- Changing a SP
ALTER PROCEDURE OrdersSelectAll @customerID int
AS
SELECT * FROM orders 
WHERE customerID = @customerID

-- Removing a SP
DROP PROCEDURE OrdersSelectAll

/* Return value of SP
-- After execution a SP returns a value
-- (*) Of type int
-- (*) Default return value = 0
-- RETURN statement => Execution of SP stops
-- Return value can be specified
*/

-- Creation of SP with explicit return value
CREATE PROCEDURE OrdersSelectAll AS
SELECT * FROM Orders
RETURN @@ROWCOUNT

-- Use of SP with return value. 
-- Result of print comes in Messages tab. 
DECLARE @numberOfOrders INT
EXEC @numberOfOrders = OrdersSelectAll
PRINT 'Number of orders = ' + STR(@numberOfOrders)


/* SP with parameters
-- A parameter is passed to the SP with an input parameter
-- With an output you can possibly pass a value to the SP and get a value back
-- You can use default values for parameters
*/

CREATE PROCEDURE OrdersSelectAllForCustomer @customerID int = 5, @numberOfOrders int OUTPUT
AS
SELECT @numberOfOrders = COUNT(*)
FROM orders
WHERE customerID = @customerID

/* Calling the SP
-- Always provide keyword OUTPUT for output parameters
-- 2 ways to pass actual parameters
	(*) use formal parameter name (order unimportant)
	(*) positional
*/

-- Pass param by explicit use of formal parameters
DECLARE @nmbrOfOrders INT
EXECUTE OrdersSelectAllForCustomer @customerID = 5, @numberOfOrders = @nmbrOfOrders OUTPUT
PRINT @numberOfOrders

-- Positional parameter passing
DECLARE @nmbrOfOrders INT
EXECUTE OrdersSelectAllForCustomer 5, @nmbrOfOrders OUTPUT
PRINT @numberOfOrders





/****************************/
/** Error handling         **/
/****************************/

/*
RETURN --> Immediate end of execution of the batch procedure
@@error --> Contains error number of last executed SQL instruction + Value = 0 if OK
RAISERROR --> Returns user defined error or system error
Use of TRY …. CATCH block
*/

/** Error handling --> First approach = using @@error **/

CREATE OR ALTER PROCEDURE ProductInsert @productName nvarchar(50) = NULL, @categoryID int = NULL AS 
DECLARE @errormsg int
INSERT INTO Products(ProductName, CategoryID, Discontinued) 
VALUES (@productName,@categoryID, 0)

-- save @@error to avoid overwriting by consecutive statements
SET @errormsg = @@error 

IF @errormsg = 0
	PRINT 'SUCCESS! The product has been added.'
ELSE IF @errormsg = 515 
	PRINT 'ERROR! ProductName is NULL.'
ELSE IF @errormsg = 547 
	PRINT 'ERROR! CategoryID doesn''t exist.' 
ELSE PRINT 'ERROR! Unable to add new product. Error:' + str(@errormsg) 

RETURN @errormsg

-- Testcode
BEGIN TRANSACTION
EXEC ProductInsert 'Wokkels', 10
SELECT * FROM Products WHERE productName LIKE '%Wokkels%'
ROLLBACK;

/** Error handling --> Second approach = using RAISERROR **/

CREATE OR ALTER PROCEDURE ProductInsert @productName nvarchar(50) = NULL, @categoryID int = NULL AS 
DECLARE @errormsg int
INSERT INTO Products(ProductName, CategoryID, Discontinued) 
VALUES (@productName,@categoryID, 0)

-- save @@error to avoid overwriting by consecutive statements
SET @errormsg = @@error 

IF @errormsg = 0
	PRINT 'SUCCESS! The product has been added.'
ELSE IF @errormsg = 515 
	RAISERROR ('ProductName or CategoryID is NULL.',18,1)
ELSE IF @errormsg = 547 
	RAISERROR ('CategoryID doesn''t exist.',18,1) 
ELSE PRINT 'ERROR! Unable to add new product. Error:' + str(@errormsg) 

RETURN @errormsg

-- Testcode
BEGIN TRANSACTION
EXEC ProductInsert 'Wokkels', 10
SELECT * FROM Products WHERE productName LIKE '%Wokkels%'
ROLLBACK;


/** Exception handling: catch-block functions **/
/*
ERROR_LINE(): line number where exception occurred
ERROR_MESSAGE(): error message
ERROR_PROCEDURE(): SP where exception occurred
ERROR_NUMBER(): error number
ERROR_SEVERITY(): severity level
*/

CREATE OR ALTER PROCEDURE DeleteShipper @ShipperID int = NULL, @NumberOfDeletedShippers int OUT
AS
BEGIN
	BEGIN TRY
		DELETE FROM Shippers WHERE ShipperID = @ShipperID
		SET @NumberOfDeletedShippers = @@ROWCOUNT
	END TRY
	BEGIN CATCH
		PRINT 'Error Number = ' + STR(ERROR_NUMBER());
		PRINT 'Error Procedure = ' + ERROR_PROCEDURE(); 
		PRINT 'Error Message = ' + ERROR_MESSAGE();
	END CATCH
END

-- Testcode
BEGIN TRANSACTION
DECLARE @nrOfDeletedShippers int;
EXEC DeleteShipper 3, @nrOfDeletedShippers OUT;
PRINT 'Number of deleted shippers ' + STR(@nrOfDeletedShippers);
ROLLBACK

/** Throw **/
/*
- Is an alternative to RAISERROR
- Without parameters: only in catch block (= rethrowing)
- With parameters: also outside catch block
*/

-- Throw: Example 1 - Without parameters => rethrowing the exception

CREATE OR ALTER PROCEDURE DeleteShipper @ShipperID int = NULL, @NumberOfDeletedShippers int OUT
AS
BEGIN
	BEGIN TRY
		DELETE FROM Shippers WHERE ShipperID = @ShipperID
		SET @NumberOfDeletedShippers = @@ROWCOUNT
	END TRY
	BEGIN CATCH
		PRINT 'This is an error';
		THROW	-- if you put this in comment => the exception is caught and isn't shown in Messages
	END CATCH
END

-- Testcode
BEGIN TRANSACTION
DECLARE @nrOfDeletedShippers int;
EXEC DeleteShipper 3, @nrOfDeletedShippers OUT;
PRINT 'Number of deleted shippers ' + STR(@nrOfDeletedShippers);
ROLLBACK

-- Throw: Example 2 - With parameters => create your own user defined exception

CREATE OR ALTER PROCEDURE DeleteShipper @ShipperID int = NULL, @NumberOfDeletedShippers int OUT
AS
BEGIN
	BEGIN TRY
		DELETE FROM Shippers WHERE ShipperID = @ShipperID
		SET @NumberOfDeletedShippers = @@ROWCOUNT
	END TRY
	BEGIN CATCH
		PRINT 'This is an error';
		THROW 50001, 'The shipper isn''t deleted', 1
	END CATCH
END

-- Testcode
BEGIN TRANSACTION
DECLARE @nrOfDeletedShippers int;
EXEC DeleteShipper 3, @nrOfDeletedShippers OUT;
PRINT 'Number of deleted shippers ' + STR(@nrOfDeletedShippers);
ROLLBACK

-- DeleteShipper revisited

CREATE OR ALTER PROCEDURE DeleteShipper @ShipperID int = NULL, @NumberOfDeletedShippers int OUT
AS
BEGIN
IF @ShipperID IS NULL
BEGIN
	PRINT 'Please provide a shipperID'
	RETURN
END

IF NOT EXISTS (SELECT * FROM Shippers where ShipperID = @ShipperID)
BEGIN
	PRINT 'The shipper doesn''t exist.'
	RETURN
END

IF EXISTS (SELECT * FROM Orders where ShipVia = @ShipperID)
BEGIN
	PRINT 'The shipper already has orders and can''t be deleted.'
	RETURN
END

DELETE FROM Shippers WHERE ShipperID = @ShipperID
PRINT 'The shipper has been succesfully deleted'

END

-- Testcode
BEGIN TRANSACTION
DECLARE @nrOfDeletedShippers int;
EXEC DeleteShipper NULL, @nrOfDeletedShippers OUT;
PRINT 'Number of deleted shippers ' + STR(@nrOfDeletedShippers);
ROLLBACK


-- SP Example: Insert Shipper with identity
CREATE OR ALTER PROCEDURE InsertShipper @CompanyName NVARCHAR(40), @phone NVARCHAR(24) = NULL, @shipperID INT OUT
AS
INSERT INTO Shippers(CompanyName, Phone)
VALUES (@CompanyName, @Phone)

SET @shipperID = @@identity

-- Testcode
BEGIN TRANSACTION
DECLARE @NewShipperID INT;
EXEC InsertShipper 'Solid Shippings', '(503) 555-9874', @NewShipperID OUT;
PRINT 'ID of inserted shipper: ' + STR(@NewShipperID);
ROLLBACK




/****************************/
/** User defined functions **/
/****************************/

-- Write a function that calculates the netto salary per month for each employee
-- If salary <= 40000 EUR per year => tax is 30%
-- If salary <= 55000 EUR per year => tax is 35%
-- Else => tax is 40%


CREATE OR ALTER FUNCTION CalculateNettoPerMonth (@salary Money)
RETURNS Money
AS
BEGIN
	RETURN
		CASE -- kan ook met IF ... ELSE ... THEN maar dit is mooier.
			WHEN @salary <= 40000 THEN @salary * 0.7 / 12
			WHEN @salary <= 55000 THEN @salary * 0.65 / 12
			ELSE @salary * 0.6 / 12
		END
END



-- Give an overview of firstname, lastname, birthdate, salary and netto salary for each employee
SELECT lastname, firstname, birthdate, salary, dbo.CalculateNettoPerMonth(salary) As NettoSalaryPerMonth
FROM employees


-- Give an overview of all employees that earn more than 2800 netto each month
SELECT lastname, firstname, birthdate, salary, Northwind.dbo.CalculateNettoPerMonth(salary) As NettoSalaryPerMonth
FROM employees
WHERE dbo.CalculateNettoPerMonth(salary) > 2800



/************************************************/
/** Inline Table Valued User defined functions **/
/************************************************/
-- Give per category the price of the cheapest product that costs more than x € and all products with that price

create function cheapest (@limit int) returns table
as
return 
select CategoryID cat, MIN(UnitPrice) minprice
from Products where UnitPrice > @limit
group by CategoryID;

-- use: 
select p.CategoryID,p.ProductID,p.UnitPrice,m.minprice
from Products p join cheapest(5) m on p.CategoryID = m.cat
where p.UnitPrice=m.minprice

/*
Besides views, subqueries and CTE's, this is another way to reuse SELECT statements, now even parameterised! 
This is called an inline table valued function because it returns a table in a single SELECT statement in the return. 
*/


