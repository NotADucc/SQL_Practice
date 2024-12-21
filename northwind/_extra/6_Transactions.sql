/***************************/
/** DATABASE TRANSACTIONS **/
/***************************/
/*
1. ACID PROPERTIES
2. TRANSACTIONS AND BATCH FLOW
3. NESTED TRANSACTIONS
4. TRANSACTIONS AND STORED PROCEDURES
5. TRANSACTIONS AND TRIGGERS
6. TYPICAL CONCURRENCY PROBLEMS
7. LOCKING
8. TRANSACTION ISOLATION LEVELS
9. DEADLOCKS
10. WHAT HAPPENS AT UPDATE TIME
*/

-- 1. ACID PROPERTIES 
-- Definition of transaction = logical unit of work, a single, indivisable task (= Atomic)
-- Example (Northwind): insert a line in the table Orderdetails and Decrement UnitsInStock with the Quantity of ordered items. 
USE Northwind
BEGIN TRAN
	INSERT INTO OrderDetails (OrderID,ProductID,UnitPrice,Quantity,Discount) 
	VALUES (10249, 72, 60.00, 10, 0.15);
	UPDATE Products SET UnitsInStock = UnitsInStock - 10 WHERE ProductID = 72; -- Should not be executed when INSERT fails --> indivisable
COMMIT TRAN -- you can omit the word TRAN
-- ACID: atomicity, consistency, isolation, durability
-- Atomic: A transaction is single event and cannot be broken down
-- Consistency: The database is always in a stable state. Only completed transactions can be written to disk.
-- Isolation: A transaction, while in process, is only visible to itself. 
-- Durable: Once a transaction is completed, the changes are stable and permanent. 

-- COMMIT: succesfull end of transaction
-- ROLLBACK: UNsuccesfull end of transaction

-- What happens when a system failure occurs between the two statements above? 
--> TRANSACTION MANAGEMENT
--> Commit has not been reached, so result of first 1st statement is not stored (not permanent).

-- Each individual INSERT, UPDATE, DELETE or MERGE command runs in its own transaction without (BEGIN TRAN, COMMIT or ROLLBACK)
-- and is committed by default. As such it's also atomic. 
-- Example: if a DELETE statement where 100 records are about to be deleteD fails because of a single foreign key constraint
-- the complete statement fails. 

-- Example with error handling
BEGIN TRAN
	BEGIN TRY
		INSERT INTO OrderDetails (OrderID,ProductID,UnitPrice,Quantity,Discount) 
		VALUES (10249, 75, 60.00, 20, 0.15) -- Should be rolled back when update fails --> indivisable
		UPDATE Products SET UnitsInStock = UnitsInStock - 20 WHERE ProductID = 75 -- Should not be executed when INSERT fails --> indivisable
	END TRY
	BEGIN CATCH
		PRINT 'ERROR: ' + ERROR_MESSAGE()
		ROLLBACK TRAN
		RETURN
	END CATCH
COMMIT TRAN;

/* Exercise */
-- Write a trigger on table product that throws an exception if unitsinstock is incremented 
-- or decremented by more than 15 units
-- Check what happens with the above script
/* SOLUTION */


-- Run the previous example with another product (ProductID 6 instead of ProductID 75)
-- Otherwise you get Violation of PRIMARY KEY constraint 'PK_Order_Details'.
BEGIN TRAN
	BEGIN TRY
		INSERT INTO OrderDetails (OrderID,ProductID,UnitPrice,Quantity,Discount) 
		VALUES (10249, 6, 60.00, 20, 0.15) -- Should be rolled back when update fails --> indivisable
		UPDATE Products SET UnitsInStock = UnitsInStock - 20 WHERE ProductID = 6 -- Should not be executed when INSERT fails --> indivisable
	END TRY
	BEGIN CATCH
		PRINT 'ERROR: ' + ERROR_MESSAGE()
		ROLLBACK TRAN
		RETURN
	END CATCH
COMMIT TRAN;



-- Testcode:
select * from OrderDetails where OrderID = 10249  -- product 6 not inserted
/* END OF SOLUTION */

-- 2. TRANSACTIONS AND BATCH FLOW
/*
- Transaction control statements have no effect on program flow:
  COMMIT and ROLLBACK do not stop the execution of SQL code.
- Often statements following ROLLBACK are commands to handle the error (like RETURN)
*/

-- 3. NESTED TRANSACTIONS
/*
- Every BEGIN TRAN needs to be paired with at least one COMMIT TRAN.
- It's possible to embed one or more transactions inside another transaction.
- If a sequence of code has 9 BEGIN TRAN statements, then nine COMMIT TRAN statements are needed.
- The system function @@trancount returns the number of open transactions.
- @@trancount = 0 means SQL is in a stable state and all nested transactions have been completed.
- Example/
*/
PRINT @@trancount -- PRINTS 0
BEGIN TRAN
	INSERT INTO OrderDetails (OrderID,ProductID,UnitPrice,Quantity,Discount) 
	VALUES (10249, 75, 60.00, 20, 0.15)
	PRINT @@trancount -- PRINTS 1
	BEGIN TRAN
		UPDATE Products SET UnitsInStock = UnitsInStock - 5 WHERE ProductID = 75 -- Not interrupted by above trigger
		PRINT @@trancount -- PRINTS 2
	COMMIT TRAN
	PRINT @@trancount -- PRINTS 1
COMMIT TRAN
PRINT @@trancount -- PRINTS 0

-- 4. TRANSACTIONS AND STORED PROCEDURES
-- Example:
CREATE OR ALTER PROCEDURE sp_Customer_Insert @customerid varchar(5), @companyname varchar(25), @orderid int OUTPUT
/* insert a new customer and an order for that customer */
/* roll back the customer insert if the order insert fails */
AS
BEGIN
	BEGIN TRANSACTION
		INSERT INTO customers(customerid, companyname)
		VALUES(@customerid, @companyname)
		IF @@error <> 0 
		BEGIN
			PRINT 'Customer not inserted'
			RETURN -1    -- we don't try to insert the order if the customer insert fails
		END
		INSERT INTO orders(customerid) VALUES(@customerid)
		IF @@error <> 0 
		BEGIN       
			PRINT 'Customer and Order not inserted'
			ROLLBACK TRAN   -- will also ROLLBACK INSERT INTO CUSTOMERS
			PRINT 'tran in proc rolled back'
			RETURN -1    
		END
	SELECT @orderid = @@IDENTITY
	COMMIT TRAN
END

-- Testcode:
BEGIN TRAN
declare @neworder int
exec sp_Customer_Insert 'ALFKI', 'New customer',@neworder
print 'New order number: ' + str(@neworder)
ROLLBACK TRAN

/* If we execute the above code, the customer insert fails because CustomerID 'ALFKI' already exists. 
However, we get the error message:
Msg 266, Level 16, State 2, Procedure sp_Customer_Insert, Line 0 [Batch Start Line 122]
Transaction count after EXECUTE indicates a mismatching number of BEGIN and COMMIT statements. Previous count = 1, current count = 2.

This is due to the fact that 
(1) This is a nested transaction 
(2) The @@trancount at the beginning of the stored procedure execution is not the same as 
    at the RETURN -1 when the customer is not inserted, so the ROLLBACK TRAN in the testcode (that expects @@trancount=1) 
	gets  @@trancount=2
(3) The ROLLBACK statement in the stored procedure rollbacks all open transactions. 
(4) The @@trancount at the start of a stored procedure needs to be the same as a the end. 
SOLUTION: replace ROLLBACK with COMMIT before RETURN -1
*/
CREATE OR ALTER PROCEDURE sp_Customer_Insert @customerid varchar(5), @companyname varchar(25), @orderid int OUTPUT
/* insert a new customer and an order for that customer */
/* roll back the customer insert if the order insert fails */
AS
BEGIN
	print '5 ' +str(@@trancount)
	BEGIN TRANSACTION
		print '6 ' +str(@@trancount)
		INSERT INTO customers(customerid, companyname)
		VALUES(@customerid, @companyname)
		IF @@error <> 0 
		BEGIN
			PRINT 'Customer not inserted'
			COMMIT TRAN -- has no effect on the transaction but needed to decrement @@transcount
			print '7 ' +str(@@trancount)
			RETURN -1    -- we don't try to insert the order if the customer insert fails
		END
		INSERT INTO orders(customerid) VALUES(@customerid)
		IF @@error <> 0 
		BEGIN       
			PRINT 'Customer and Order not inserted'
			ROLLBACK TRAN   -- will also ROLLBACK INSERT INTO CUSTOMERS
			PRINT 'tran in proc rolled back'
			RETURN -1    
		END
	SELECT @orderid = @@IDENTITY
	print '8 ' +str(@@trancount)
	COMMIT TRAN
	print '9 ' +str(@@trancount)
END

-- Testcode:
print '1 '+str(@@trancount)
BEGIN TRAN
print '2 '+str(@@trancount)
declare @neworder int
exec sp_Customer_Insert 'ALFKI', 'New customer',@neworder
print '3 '+str(@@trancount)
print 'New order number: ' + str(isnull(@neworder,0))
ROLLBACK TRAN
print '4 ' +str(@@trancount)

/* Remark: the correct handling of the second error condition where the ROLLBACK is really needed is beyond the scope of this course.
Conclusion: try to avoid nested transactions as much as possible */

-- 5. TRANSACTIONS AND TRIGGERS
/*
- A trigger is part of the same transaction as the triggering instruction.
- Inside the trigger this transaction can be ROLLBACKed.
- Although a trigger in SQL Server occurs after the triggering instruction, that instruction can still be undone in the trigger.
- Example:
*/
-- If a new record is inserted in OrderDetails => check if the unitPrice is not too low or too high
CREATE OR ALTER TRIGGER insertOrderDetails ON OrderDetails FOR insert
AS
	DECLARE @insertedProductID INT = (SELECT ProductID From inserted) -- assume only one product is inserted with an INSERT statement
	DECLARE @insertedUnitPrice Money = (SELECT UnitPrice From inserted)
	DECLARE @unitPriceFromProducts Money = (SELECT UnitPrice FROM Products WHERE ProductID = @insertedProductID)
	IF @insertedUnitPrice NOT BETWEEN @unitPriceFromProducts * 0.85 AND @unitPriceFromProducts * 1.15
	BEGIN
		ROLLBACK TRANSACTION 
		RAISERROR ('The inserted unit price can''t be correct', 14,1)
		RETURN
	END 
-- 6. TYPICAL CONCURRENCY PROBLEMS
/*
In a multi-process environment process (or transacion) execution is often interrupted
(while e.g. waiting for IO) by the execution of (parts of) another process aso. 
However, this approach can cause several problems:
- LOST UPDATE
	Occurs if an otherwise successful update of a data item by a transaction is overwritten by another transaction 
	that wasn’t ‘aware’ of the first update.
- UNCOMMITTED DEPENDENCY (a.k.a. DIRTY READ)
	Occurs if a transaction reads one or more data items that are being updated by another, 
	as yet uncommitted, transaction. 
- NONREPEATABLE READ (UNREPEATABLE READ)
	Occurs when a transaction T1 reads the same row multiple times, but obtains different subsequent values, 
	because another transaction T2 updated this row in the meantime.
- PHANTOM READ
	Occurs when a transaction T2 is executing insert or delete operations on a set 
	of rows that are being read by a transaction T1. 
	So new rows suddenly appear during the read of T1 = phantoms.

*/
-- 7. LOCKING
/*
- Purpose of locking is to ensure that, in situations where different concurrent transactions 
attempt to access the same database object, access is only granted in such a way that no conflicts can occur.
- A lock is a variable that is associated with a database object, where the variable’s value 
constrains the types of operations that are allowed to be executed on the object at that time.
- The lock manager is responsible for granting locks (locking) and releasing locks (unlocking) by applying a locking protocol.

There are 3 basis lock modes: shared, exclusive and update
- An exclusive lock (x-lock or write lock) means that a single transaction acquires the sole privilege 
  to interact with that specific database object at that time no other transactions are allowed to read or write it.
  Used by INSERT, UPDATE and DELETE.
- A shared lock (s-lock or read lock) guarantees that no other transactions will update that same object 
  for as long as the lock is held: other transactions may hold a shared lock on that same object as well, 
  however they are only allowed to read it. Used by SELECT statements.
- Update locks are designed to prevent a condition called a deadlock. A deadlock occurs if 2 or more transactions 
  are waiting for one another’s’ locks to be released.  An update lock will begin similar to a shared lock, allowing a
  process to read information it requires for its transaction but when it becomes necessary to modify the data, 
  the lock will transition to an exclusive lock.*/

/** LOCK GRANULARITY **/
/*
- refers to the size of the resource being locked
- smallest = row of data
- largest = entire database
- larger locks require fewer locks and easier lock management but do not allow for much concurrency when accessing data. 
- The system automatically chooses the appropriate lock granularity.
- In most cases we can assume locking occurs on row level. 
*/

-- 8. TRANSACTION ISOLATION LEVELS

/* A transaction isolation level describes the degree of isolation a transaction is in 
with regard to outside processes. 

4 different types of isolation levels are in use in SQL Server:
(from lower isolation to higher isolation)
- READ UNCOMMITTED
	* Allows for "dirty reads", the reading of uncommitted data by outside transactions.
- READ COMMITTED (= default)
	* Allows only data that has been committed to be accessed. 
	* Data that has been modified will be exclusively locked until the transaction has been committed. 
- REPEATABLE READ
	* Allows for data when read in a transaction to be re-readable within that same transaction. 
	* This can prevent data that was read earlier in a transaction from being changed by someone else. 
	* Thus, a transaction can read the same row repeatedly, without interference from insert, update or delete operations by other transactions.  
- SERIALIZABLE
	* REPEATABLE READ only locks rows found with first SELECT
	* Same SELECT in same transaction can give new rows (added by other transactions) = phantoms
	* Serializable avoids phantoms
	* Locks all keys (current and future) that correspond to WHERE-clause

You can set the isolation level with following command: 
SET TRANSACTION ISOLATION LEVEL 
{
	READ UNCOMMITTED
	| READ COMMITTED
	| REPEATABLE READ
	| SERIALIZABLE
}

A higher isolation level means:
- locks take longer
- more consistency
- less concurrency
*/
/* EXAMPLES */
/* Since all examples deal with concurrency we need 2 parallel database sessions (e.g. 2 windows in SSMS) 
and have to interweave the commands in the given order */
-- EXCLUSIVE LOCK WITH READ COMMITTED
-- Session 1
-- 1
BEGIN TRAN
select productid,unitprice 
from Products 
where ProductID = 1;

--3
update Products
set UnitPrice = 20
where ProductID = 1;
-- new value is only visible for own process

-- 4
select productid,unitprice 
from Products 
where ProductID = 1;

-- 6
COMMIT TRAN
-- End of session 1

-- Session 2
-- 2
select productid,unitprice 
from Products 
where ProductID = 1;

-- 5
select productid,unitprice 
from Products 
where ProductID = 1;
-- locked until Session 1 commits
-- End of session 2

-- DIRTY READ WITH READ UNCOMMITTED
-- Session 1
-- 1
BEGIN TRAN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
select productid,unitprice 
from Products 
where ProductID = 1;

--3
update Products
set UnitPrice = 22
where ProductID = 1;
-- new value also visible in other process

-- 4
select productid,unitprice 
from Products 
where ProductID = 1;

-- 6
ROLLBACK TRAN
-- Update of unit price will never become permanent 
-- but has been read by session 2
-- End of session  1

-- Session 2
-- 2
BEGIN TRAN
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
select productid,unitprice 
from Products 
where ProductID = 1;

-- 5
select productid,unitprice 
from Products 
where ProductID = 1;
-- sees new value even before commit

-- 6
select productid,unitprice 
from Products 
where ProductID = 1;

COMMIT TRAN
-- End of session 2

/* Conclusion: execution with READ UNCOMMITTED is faster
(no locks) but you have to deal with (occasional) dirty reads. */

-- FIND NEW PRIMARY KEY:
-- Session 1
-- 1
-- CREATE NEW SHIPPER 
-- Without special arrangements for transactions
-- -->  Each statement runs in its own transaction
DECLARE @newid int = (select MAX(shipperid) from Shippers)
SELECT @newid
/* For the purpose of this demo we use sp_set_session_context to the keep variables 
between the execution of the different batches. In a real-life situation
this would not be needed */
EXEC sys.sp_set_session_context @key='newid', @value=@newid

-- 3
-- read variable from session_context
DECLARE @newid int = (SELECT CONVERT(int, SESSION_CONTEXT(N'newid')));

INSERT INTO Shippers VALUES
(@newid+1,'New shipper 1',null)

--> PK violation: in the meantime session 2 took the new key. 

-- End of session 1

-- Session 2 (of same application)
-- 2
-- CREATE NEW SHIPPER 
DECLARE @newid int = (select MAX(shipperid) from Shippers)
SELECT @newid

INSERT INTO Shippers VALUES
(@newid+1,'New shipper 2',null)

SELECT TOP 1 * FROM Shippers ORDER BY ShipperID DESC;

-- End of session 2

-- SOLUTION 1:
-- Insert in a single statement: atomicity ensures correct execution
INSERT INTO Shippers VALUES
((select MAX(shipperid) + 1 from Shippers), 'New shipper 1',null)

-- SOLUTION 2:
-- Use an identity value for the primary key, but this is not always 
-- possible for an existing application as it might break application code

-- 9. DEADLOCKS
/*
- Occurs when processes block each other in such a fashion that neither process 
can proceed until the other completes. 
- Database servers are designed to detect this situation and remedy it. 
- The server will kill the process with the least amount of time on the system. 
Example:
*/
-- Session 1
-- 1
BEGIN TRAN
-- Use default isolation level READ COMMITTED
SELECT EmployeeID,Salary from Employees where EmployeeID=1;

UPDATE Employees SET Salary = Salary+5000 where EmployeeID=1;

SELECT EmployeeID,Salary from Employees where EmployeeID=1;

-- 3

SELECT employeeid,salary from Employees where EmployeeID=2;
-- Session 1 has to wait because session 2 holds an exclusive lock on this record

-- 5
COMMIT TRAN

-- End of session 1

-- Session 2 
-- 2
BEGIN TRAN
-- Use default isolation level READ COMMITTED
SELECT employeeid,salary from Employees where EmployeeID=2;

UPDATE Employees SET Salary = Salary+5000 where EmployeeID=2;

SELECT EmployeeID,Salary from Employees where EmployeeID=2;

-- 4
SELECT EmployeeID,Salary from Employees where EmployeeID=1;
-- Session 2 has to wait too because session 1 holds an exclusive lock on this record
-- A deadlock occurs and one of the processes is chosen as the victim.

-- 6
SELECT EmployeeID,Salary from Employees where EmployeeID=1;
COMMIT TRAN

-- End of session 2

-- 10. WHAT HAPPENS AT UPDATE TIME? 
/*
- SQL Server has a write-ahead log: 
	1. It first logs the changes for the pages (page=unit of IO) to be modified.
	2. Then it makes the changes. 
	3. Finally it logs that the changes or complete (the actual commit).
- Changes to in-memory pages are not immediately flushed to disk with commit. 
- If a system failure occurs after commit but before the flush, upon restart of the system
  the logfile is used to "play back" the changes. 
- The logfile is a very important file than can best be stored an on a separate disk and backed up frequently. 
*/

