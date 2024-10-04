/* Common Table Expression */

/* Common Table Expression: The WITH component */

-- Give per category the minimum price and all products with that minimum price 

-- Solution 1
SELECT CategoryID, ProductID, UnitPrice
FROM Products p
WHERE UnitPrice = (SELECT MIN(UnitPrice) FROM Products WHERE CategoryID = p.CategoryID)


-- Not performant! Loops through all products and calculates the MIN(unitprice) for the category of that specific product: O(n²)
-- The MIN(unitprice) is calculated multiple times for each category!


-- Solution 2
WITH CategoryMinPrice(CategoryID, MinPrice)
AS (SELECT CategoryID, MIN(UnitPrice)
    FROM Products AS p
    GROUP BY CategoryID)

SELECT c.CategoryID, p.ProductID, MinPrice
FROM Products AS p
JOIN CategoryMinPrice AS c ON p.CategoryID = c.CategoryID AND p.UnitPrice = c.MinPrice;

-- Using the WITH-component you can give the subquery its own name (with column names) and reuse it in the rest of the query (possibly several times!)


-- Give per category all products that cost less than the average price of that category





-- Give all products from the same category As Tofu, that are not Tofu




--The columns in the CTE should have a name, so
--you can refer to these columns.
--(1) If not given a name, it will use the 'default' name(e.g. customerid, COUNT(orderid))
--(2) Or you can specify the columnname in the 'header' of the CTE
WITH CategoryMinPrice(CategoryID, MinPrice)
AS (SELECT CategoryID, MIN(UnitPrice)
    FROM Products AS p     
    GROUP BY CategoryID)

SELECT c.CategoryID, p.ProductID, MinPrice
FROM Products AS p
JOIN CategoryMinPrice AS c ON p.CategoryID = c.CategoryID AND p.UnitPrice = c.MinPrice;


--(3) Or you can give each column a name in the CTE. 
WITH CategoryMinPrice
AS (SELECT CategoryID As CategoryID, MIN(UnitPrice) AS MinPrice
    FROM Products AS p
    GROUP BY CategoryID)

SELECT c.CategoryID, p.ProductID, MinPrice
FROM Products AS p
JOIN CategoryMinPrice AS c ON p.CategoryID = c.CategoryID AND p.UnitPrice = c.MinPrice;

-- the WITH-component has two application areas:
--		Simplify SQL-instructions, e.g. simplified alternative for simple subqueries or avoid repetition of SQL constructs 
--		Traverse recursively hierarchical and network structures


/* CTE's versus Views 

Similarities 
- WITH ~ CREATE VIEW
- Both are virtual tables: the content is derived from other tables

Differences 
- A CTE only exists during the SELECT-statement
- A CTE is not visible for other users and applications
*/


/* CTE's versus Subqueries 
Similarities 
- Both are virtual tables:  the content is derived from other tables

Differences 
- A CTE can be reused in the same query
- A subquery is defined in the clause where it is used (SELECT/FROM/WHERE/…)
- A CTE is defined on top of the query
- A simple subquery can always be replaced by a CTE
*/

-- CTE's with > 1 WITH-component

-- Give per year per customer the relative contribution of this customer to the total revenue

-- Step 1 -> Total revenue per year
SELECT YEAR(OrderDate), SUM(od.UnitPrice * od.Quantity)
FROM Orders o INNER JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate)

-- Step 2 -> Total revenue per year per customer
SELECT YEAR(OrderDate), o.CustomerID, SUM(od.UnitPrice * od.Quantity)
FROM Orders o INNER JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate), o.CustomerID

-- Step 3 -> Combine both
WITH TotalRevenuePerYear(RevenueYear, TotalRevenue)
AS
(SELECT YEAR(OrderDate), SUM(od.UnitPrice * od.Quantity)
FROM Orders o INNER JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate)),

TotalRevenuePerYearPerCustomer(RevenueYear, CustomerID, Revenue) 
AS
(SELECT YEAR(OrderDate), o.CustomerID, SUM(od.UnitPrice * od.Quantity)
FROM Orders o INNER JOIN OrderDetails od
ON o.OrderID = od.OrderID
GROUP BY YEAR(OrderDate), o.CustomerID)

SELECT CustomerID, pc.RevenueYear, FORMAT(Revenue / TotalRevenue, 'P') As RelativePart
FROM TotalRevenuePerYearPerCustomer pc INNER JOIN TotalRevenuePerYear t 
ON pc.RevenueYear = t.RevenueYear
ORDER BY 2 ASC, 3 DESC


-- Give the employees that process more orders than average
-- cte1 --> the number of processed orders per employee
-- cte2 --> the average
-- employees with number of processed orders > average







/* Recursive SELECT's */

/*
'Recursive' means: we continue to execute a table expression until a condition is reached.

This allows you to solve problems like:
- Who are the friends of my friends etc. (in a social network)?
- What is the hierarchy of an organisation ? 
- Find the parts and subparts of a product (bill of materials). 

*/

-- Give the integers from 1 to 5
WITH numbers(number) AS
	(SELECT 1 
	 UNION all 
 	 SELECT number + 1 
	 FROM numbers
 	 WHERE number < 5)

SELECT * FROM numbers;

/* Characteristics of recursive use of WITH:
- The with component consists of (at least) 2 expressions, combined with UNION ALL
- A temporary table is consulted in the second expression
- At least one of the expressions may not refer to the temporary table.
*/

-- Give the numbers from 1 to 999

WITH numbers(number) AS
	(SELECT 1 
	 UNION all 
 	 SELECT number + 1 
	 FROM numbers
 	 WHERE number < 999)

SELECT * FROM numbers;

--> The maximum recursion 100 has been exhausted before statement completion.

-- Give the numbers from 1 to 999

WITH numbers(number) AS
	(SELECT 1 
	 UNION all 
 	 SELECT number + 1 
	 FROM numbers
 	 WHERE number < 999)

SELECT * FROM numbers
option (maxrecursion 1000);

--> Maxrecursion is MS SQL Server specific. 

-- Give the total revenue per month in 2016.Not all months occur

SELECT YEAR(OrderDate)*100 + Month(OrderDate) AS RevenueMonth, SUM(od.UnitPrice * od.Quantity) AS Revenue
FROM Orders o INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE YEAR(OrderDate) = 2016
GROUP BY YEAR(OrderDate)*100 + Month(OrderDate)

-- Solution: Generate all months with CTE ...
note

-- And combine with outer join
WITH Months(RevenueMonth) AS
(SELECT 201601 as RevenueMonth
UNION ALL
SELECT RevenueMonth + 1
FROM Months
WHERE RevenueMonth < 201612),

Revenues(RevenueMonth, Revenue)
AS
(SELECT YEAR(OrderDate)*100 + Month(OrderDate) AS RevenueMonth, SUM(od.UnitPrice * od.Quantity) AS Revenue
FROM Orders o INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
WHERE YEAR(OrderDate) = 2016
GROUP BY YEAR(OrderDate)*100 + Month(OrderDate))

SELECT m.RevenueMonth, ISNULL(r.Revenue, 0) As Revenue
FROM Months m LEFT JOIN Revenues r ON m.RevenueMonth = r.RevenueMonth



/* Recursively traversing a hierarchical structure */

-- Give all employees who report directly or indirectly to Andrew Fuller (employeeid=2)
-- Step 1 returns all employees that report directly to Andrew Fuller
-- Step 2 adds the 2nd 'layer': who reports to someone who reports to A. Fuller
-- ....

WITH Bosses (boss, emp)
AS
(SELECT ReportsTo, EmployeeID
FROM Employees
WHERE ReportsTo IS NULL
UNION ALL
SELECT e.ReportsTo, e.EmployeeID
FROM Employees e INNER JOIN Bosses b ON e.ReportsTo = b.emp)

SELECT * FROM Bosses
ORDER BY boss, emp;

-- Change the previous solution to the following solution
/*
boss	emp		title					level	path
NULL	2		Vice President, Sales	1		Vice President, Sales
2		5		Sales Manager			2		Vice President, Sales<--Sales Manager
2		10		Business Manager		2		Vice President, Sales<--Business Manager
2		13		Marketing Director		2		Vice President, Sales<--Marketing Director
5		1		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
5		3		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
5		4		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
5		6		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
5		7		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
5		8		Inside Sales Coordinator	3	Vice President, Sales<--Sales Manager<--Inside Sales Coordinator
5		9		Sales Representative	3		Vice President, Sales<--Sales Manager<--Sales Representative
...
*/

WITH Bosses (boss, emp, title, level, path)
AS
(SELECT ReportsTo, EmployeeID, Title, 1, convert(varchar(max), Title)
FROM Employees
WHERE ReportsTo IS NULL
UNION ALL
SELECT e.ReportsTo, e.EmployeeID, e.Title, b.level + 1, convert(varchar(max), b.path + '<--' + e.title)
FROM Employees e INNER JOIN Bosses b ON e.ReportsTo = b.emp)

SELECT * FROM Bosses
ORDER BY boss, emp;
