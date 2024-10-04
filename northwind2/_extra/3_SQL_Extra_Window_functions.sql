/* Window functions */

/*
• Often business managers want to compare current sales to previous sales
• Previous sales can be:
– sales during the previous month
– average sales during the last three months
– last year’s sales until current date (year-to-date)
• Window functions offer a solution to these kind of problems in a single, efficient SQL query
• Introduced in SQL: 2003

OVER clause
• Results of a SELECT are partitioned
• Numbering, ordering and aggregate functions per partition
• The OVER clauses creates partitions and ordering
• The partition behaves as a window that shifts over the data
• The OVER clause can be used with standard aggregate functions
(sum, avg, …) or specific window functions (rank, lag,…)

*/

-- Example
-- Make an overview of the UnitsInStock per Category and per Product
SELECT CategoryID, ProductID, UnitsInStock
FROM Products
order by CategoryID, ProductID

-- Add an extra column to calculate the running total of UnitsInStock per Category
-- Solution 1 -> correlated subquery
SELECT CategoryID, ProductID, UnitsInStock,
(SELECT SUM(UnitsInStock) 
 FROM Products 
 WHERE CategoryID = p.CategoryID  
  and ProductID <= p.ProductID) TotalUnitsInStockPerCategory
FROM Products p
order by CategoryID, ProductID;

-- Using a correlated subquery is very inefficient as for each line the complete sum is recalculated


-- Solution 2 -> OVER clause => simpler + more efficient
-- The sum is calculated for each partition
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY ProductID) TotalUnitsInStockPerCategory
FROM Products



/* RANGE */
/*
Real meaning of window functions: apply to a window that shifts over the result set
The previous query works with the default window: start of resultset to current row
*/

-- the previous query is the shorter version of the following query. Exactly the same resultset!
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY ProductID RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) TotalUnitsInStockPerCategory
FROM Products




/*
With RANGE you have three valid options:
- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
- RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING 
- RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
PARTITION is optional, ORDER BY is mandatory
*/

-- RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY  ProductID RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) TotalUnitsInStockPerCategory
FROM Products


-- RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING 
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY ProductID RANGE BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) TotalUnitsInStockPerCategory
FROM Products


-- RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
SELECT CategoryID, ProductID, UnitsInStock,
SUM(UnitsInStock) OVER (PARTITION BY CategoryID ORDER BY ProductID RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) TotalUnitsInStockPerCategory
FROM Products





/* ROWS */
/*
When you use RANGE, the current row is compared to other rows and grouped based on the ORDER BY predicate. 
This is not always desirable. You might actually want a physical offset.
In this scenario, you would specify ROWS instead of RANGE. This gives you three options in addition to the three options enumerated previously:
- ROWS BETWEEN N PRECEDING AND CURRENT ROW
- ROWS BETWEEN CURRENT ROW AND N FOLLOWING 
- ROWS BETWEEN N PRECEDING AND N FOLLOWING 
*/

-- Make an overview of the salary per employee and the average salary of this employee and the 2 employees preceding him

SELECT EmployeeID, FirstName + ' ' + LastName As FullName,  Salary, AVG(Salary) OVER (ORDER BY Salary DESC ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) As AvgSalary2Preceding
FROM Employees

-- Make an overview of the salary per employee and the average salary of this employee and the 2 employees following him

SELECT EmployeeID, FirstName + ' ' + LastName As FullName,  Salary, AVG(Salary) OVER (ORDER BY Salary DESC ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) As AvgSalary2Following
FROM Employees

-- Make an overview of the salary per employee and the average salary of this employee and the employee preceding and following him

SELECT EmployeeID, FirstName + ' ' + LastName As FullName,  Salary, AVG(Salary) OVER (ORDER BY Salary DESC ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) As AvgSalary1Preceding1Following
FROM Employees


/* WINDOW FUNCTIONS */
/*
ROW_NUMBER() numbers the output of a result set. More specifically, 
returns the sequential number of a row within a partition of a result set, starting at 1 for the first row in each partition.

RANK() returns the rank of each row within the partition of a result set. 
The rank of a row is one plus the number of ranks that come before the row in question.

ROW_NUMBER and RANK are similar. ROW_NUMBER numbers all rows sequentially (for example 1, 2, 3, 4, 5). 
RANK provides the same numeric value for ties (for example 1, 2, 2, 4, 5).

DENSE_RANK() returns the rank of each row within the partition of a result set, with no gaps in the ranking values (for example 1, 2, 2, 3, 4).

PERCENT_RANK() shows the ranking on a scale from 0 - 1 
*/

-- Give ROW_NUMBER / RANK / DENSE_RANK / PERCENT_RANK for each employee based on his salary
SELECT EmployeeID, FirstName + ' ' + LastName As 'Full Name', Title, Salary,
ROW_NUMBER() OVER (ORDER BY Salary DESC) As 'ROW_NUMBER',
RANK() OVER (ORDER BY Salary DESC) AS 'RANK',
DENSE_RANK() OVER (ORDER BY Salary DESC) AS 'DENSE_RANK',
PERCENT_RANK() OVER (ORDER BY Salary DESC) AS 'PERCENT_RANK'
FROM Employees

-- Give ROW_NUMBER / RANK / DENSE_RANK / PERCENT_RANK per title for each employee based on his salary
SELECT EmployeeID, FirstName + ' ' + LastName As 'Full Name', Title, Salary,
ROW_NUMBER() OVER (PARTITION BY Title ORDER BY Salary DESC) As 'ROW_NUMBER',
RANK() OVER (PARTITION BY Title ORDER BY Salary DESC) AS 'RANK',
DENSE_RANK() OVER (PARTITION BY Title ORDER BY Salary DESC) AS 'DENSE_RANK',
PERCENT_RANK() OVER (PARTITION BY Title ORDER BY Salary DESC) AS 'PERCENT_RANK'
FROM Employees



/* LAG */
/*
LAG refers to the previous line. This is short for LAG(…, 1)
LAG(…, 2) refers to the line before the previous line, …
*/

-- Calculate for each employee the difference in salary between this employee and the employee preceding him
SELECT EmployeeID, FirstName + ' ' + LastName,  Salary, (LAG(Salary) OVER (ORDER BY Salary DESC) - Salary) As EarnsLessThanPreceding
FROM Employees


/* LEAD */
/*
LEAD refers to the next line. This is short for LEAD(…, 1)
LEAD(…, 2) refers to the line after the next line, …
*/


-- Calculate for each employee the difference in salary between this employee and the employee following him
SELECT EmployeeID, FirstName + ' ' + LastName,  Salary, (Salary - LEAD(Salary) OVER (ORDER BY Salary DESC)) As EarnsMoreThanFollowing
FROM Employees
