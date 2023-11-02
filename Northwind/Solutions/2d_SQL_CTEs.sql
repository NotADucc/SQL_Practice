/* Exercises */


-- 1. Give all employees that started working as an employee in the same year as Robert King

-- cte --> HireYear of Robert King
WITH HireYear AS (
	SELECT YEAR(HireDate) AS Year
	FROM Employees
	WHERE CONCAT(FirstName, ' ', LastName) LIKE 'Robert King'
)
SELECT *
FROM Employees e
JOIN HireYear hy ON hy.Year = YEAR(e.HireDate)
GO


-- 2 Make a histogram of the number of orders per customer, so show how many times each number occurs. 
-- E.g.: 1 customer placed 1 order, 2 customers placed 2 orders, 7 customers placed 3 orders, etc. 

-- cte --> number of orders per customer
WITH 
OrdersPerCustomer AS (
	SELECT c.CustomerID, COUNT(c.CustomerID) AS OrderCount
	FROM Customers c
	JOIN Orders o ON c.CustomerID = o.CustomerID
	GROUP BY c.CustomerID
)
SELECT OrderCount AS NumberOfOrders, COUNT(OrderCount) as NumberOfCustomers
FROM OrdersPerCustomer
GROUP BY OrderCount
GO

--OR

WITH 
OrdersPerCustomer AS (
	SELECT c.CustomerID, COUNT(c.CustomerID) AS OrderCount
	FROM Customers c
	JOIN Orders o ON c.CustomerID = o.CustomerID
	GROUP BY c.CustomerID
),
CountOrdersPerCustomer AS(
	SELECT OrderCount AS NumberOfOrders, COUNT(OrderCount) as NumberOfCustomers
	FROM OrdersPerCustomer
	GROUP BY OrderCount
),
MaxCount AS(
	SELECT MAX(OrderCount) AS MaxCount
	FROM OrdersPerCustomer
),
RecursiveMaxCount AS(
	SELECT 1 AS NumberOfOrders
	UNION ALL
	SELECT NumberOfOrders + 1
	FROM RecursiveMaxCount
	WHERE NumberOfOrders < (SELECT MaxCount FROM MaxCount)
)
SELECT rmc.NumberOfOrders, ISNULL(copc.NumberOfCustomers, 0) as NumberOfCustomers
FROM RecursiveMaxCount rmc
LEFT JOIN CountOrdersPerCustomer copc ON rmc.NumberOfOrders = copc.NumberOfOrders
OPTION(maxrecursion 0)
GO


-- 3. Give the customers of the Country in which most customers live
--> cte1: number of customers per country
--> cte2: maximum */
WITH CustomersPerCountry AS(
	SELECT Country, COUNT(Country) AS NrOfCustomers
	FROM Customers
	GROUP BY Country
),
MostCostumersCountry AS(
	SELECT MAX(NrOfCustomers) AS MaxNumber
	FROM CustomersPerCountry
)
SELECT c.CustomerID, c.CompanyName, c.Country
FROM Customers c
JOIN (SELECT Country FROM CustomersPerCountry WHERE NrOfCustomers IN(SELECT * FROM MostCostumersCountry)) sq ON c.Country = sq.Country
ORDER BY c.CompanyName
GO

--OR

WITH CustomersPerCountry AS(
	SELECT Country, COUNT(Country) AS NrOfCustomers
	FROM Customers
	GROUP BY Country
),
MostCostumersCountry AS(
	SELECT MAX(NrOfCustomers) AS MaxNumber
	FROM CustomersPerCountry
)
SELECT c.CustomerID, c.CompanyName, c.Country
FROM Customers c
JOIN CustomersPerCountry cpc ON c.Country = cpc.Country
JOIN MostCostumersCountry mcc ON cpc.NrOfCustomers = mcc.MaxNumber
ORDER BY c.CompanyName
GO

-- 4. Give all employees except for the eldest
--> birthdate of the eldest in subquery or cte

-- Solution 1 (using Subqueries)
SELECT EmployeeID, CONCAT(FirstName, ' ', LastName) AS EmployeeName, BirthDate
FROM Employees
WHERE BirthDate NOT IN(SELECT * FROM (SELECT MIN(BirthDate) AS OldestBDay FROM Employees) sq)
GO

-- Solution 2 (using CTE's)
WITH EldestEmployee AS(
	SELECT MIN(BirthDate) AS OldestBDay
	FROM Employees
)
SELECT EmployeeID, CONCAT(FirstName, ' ', LastName) AS EmployeeName, BirthDate
FROM Employees
WHERE BirthDate NOT IN(SELECT * FROM EldestEmployee)
GO


-- 5.  What is the total number of customers and suppliers?
WITH 
CustomerCTE AS(
	SELECT COUNT(*) AS CustomerCount
	FROM Customers
),
SupplierCTE AS(
	SELECT COUNT(*) AS SupplierCount
	FROM Suppliers
)
SELECT
(SELECT * FROM CustomerCTE) AS CustomerCount,
(SELECT * FROM SupplierCTE) AS SupplierCount
GO




-- 6. Give per title the eldest employee

--Can be easier with window functions but we're not there yet.
WITH BdayPerTitle AS (
	SELECT Title, BirthDate
	FROM Employees
	GROUP BY Title, BirthDate
),
EldestPerTitle AS(
	SELECT Title, MIN(BirthDate) AS Eldest
	FROM BdayPerTitle
	GROUP BY Title
)
SELECT e.EmployeeID, e.Title, e.BirthDate
FROM Employees e
JOIN EldestPerTitle ept ON e.BirthDate = ept.Eldest AND e.Title = ept.Title
GO



-- 7. Give per title the employee that earns most

--Can be easier with window functions but we're not there yet.
WITH SalaryPerTitle AS (
	SELECT Title, Salary
	FROM Employees
	GROUP BY Title, Salary
),
HighestSalaryPerTitle AS(
	SELECT Title, MAX(Salary) AS HighestEarner
	FROM SalaryPerTitle
	GROUP BY Title
)
SELECT e.EmployeeID, CONCAT(e.FirstName, ' ', e.LastName) AS FullName, e.Title, e.Salary
FROM Employees e
JOIN HighestSalaryPerTitle ept ON e.Salary = ept.HighestEarner AND e.Title = ept.Title
ORDER BY e.Salary DESC
GO


-- 8. Give the titles for which the eldest employee is also the employee who earns most

--Can be easier with window functions but we're not there yet.
WITH CompoundPerTitle AS (
	SELECT Title, BirthDate, Salary
	FROM Employees
	GROUP BY Title, BirthDate, Salary
),
HighestSalaryPerTitle AS(
	SELECT Title, MAX(Salary) AS HighestEarner
	FROM CompoundPerTitle
	GROUP BY Title
),
EldestPerTitle AS(
	SELECT Title, MIN(BirthDate) AS Eldest
	FROM CompoundPerTitle
	GROUP BY Title
)
SELECT e.EmployeeID, e.Title, e.BirthDate, e.Salary
FROM CompoundPerTitle com
JOIN EldestPerTitle ept ON com.Title = ept.Title AND com.BirthDate = ept.Eldest
JOIN HighestSalaryPerTitle hspt ON com.Title = hspt.Title AND com.Salary = hspt.HighestEarner
JOIN Employees e ON e.Title = com.Title AND e.Salary = com.Salary AND e.BirthDate = com.BirthDate
GO

-- 9. Execute the following script:
CREATE TABLE Parts 
(
    [Super]   CHAR(3) NOT NULL,
    [Sub]     CHAR(3) NOT NULL,
    [Amount]  INT NOT NULL,
    PRIMARY KEY(Super, Sub)
);

INSERT INTO Parts VALUES ('O1','O2',10);
INSERT INTO Parts VALUES ('O1','O3',5);
INSERT INTO Parts VALUES ('O1','O4',10);
INSERT INTO Parts VALUES ('O2','O5',25);
INSERT INTO Parts VALUES ('O2','O6',5);
INSERT INTO Parts VALUES ('O3','O7',10);
INSERT INTO Parts VALUES ('O6','O8',15);
INSERT INTO Parts VALUES ('O8','O11',5);
INSERT INTO Parts VALUES ('O9','O10',20);
INSERT INTO Parts VALUES ('O10','O11',25);

-- Show all parts that are directly or indirectly part of O2, so all parts of which O2 is composed.
-- Add an extra column with the path as below: 

/*
SUPER	SUB		PAD
O2		O5		O2 <-O5
O2		O6		O2 <-O6
O6		O8		O2 <-O6 <-O8
O8		O11		O2 <-O6 <-O8 <-O11

*/

WITH 
NewParts AS(
	SELECT 
	Super, 
	Sub, 
	CONVERT(varchar(MAX), Super + ' <-' + Sub) AS Pad
	FROM Parts p
	WHERE Super = 'O2'
	UNION ALL
	SELECT p.Super, p.Sub, CONVERT(varchar(MAX), np.Pad + ' <-' + p.Sub)
	FROM Parts p
	JOIN NewParts np ON p.Super = np.Sub
)
SELECT *
FROM NewParts
GO
