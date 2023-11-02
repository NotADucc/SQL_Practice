-- 1. Give the id and name of the products that have not been purchased yet. 
SELECT p.ProductID, p.ProductName
FROM Products p
WHERE p.ProductID NOT IN(
	SELECT ProductID
	FROM OrderDetails
)


-- 2. Select the names of the suppliers who supply products that have not been ordered yet.
SELECT s.CompanyName
FROM Suppliers s
WHERE s.SupplierID NOT IN(
	SELECT p.SupplierID
	FROM Products p
	JOIN OrderDetails od ON p.ProductID = od.ProductID
)

-- 3. Give a list of all customers from the same country as the customer Maison Dewey
SELECT c.CompanyName, c.Country
FROM Customers c
WHERE c.Country = (
	SELECT cc.Country 
	FROM Customers cc
	WHERE cc.CompanyName LIKE 'Maison Dewey'
)


-- 4. Give for each product how much the price differs from the average price of all products of the same category
SELECT ProductID, ProductName, UnitPrice, UnitPrice - (SELECT AVG(UnitPrice) FROM Products pp WHERE pp.CategoryID = p.CategoryID) AS differenceToCategory
FROM Products p


-- 5. Give per title the employee that was last hired sort on fullname
SELECT e.Title, CONCAT(e.FirstName, ' ', e.LastName) AS FullName, e.HireDate
FROM Employees e
WHERE HireDate = (
	SELECT TOP 1 ee.HireDate
	FROM Employees ee
	WHERE ee.Title = e.Title
	ORDER BY HireDate DESC
)
ORDER BY CONCAT(e.FirstName, ' ', e.LastName)

--OR

SELECT e.Title, CONCAT(e.FirstName, ' ', e.LastName) AS FullName, e.HireDate
FROM Employees e
WHERE HireDate = (
	SELECT MAX(HireDate)
	FROM Employees ee
	GROUP BY ee.Title
	HAVING ee.Title = e.Title
)
ORDER BY CONCAT(e.FirstName, ' ', e.LastName)


-- 6. Which employee/employees have processed the most orders? 
SELECT CONCAT(e.FirstName, ' ', e.LastName) AS FullName, (SELECT COUNT(*) FROM Orders oo WHERE oo.EmployeeID = e.EmployeeID) AS ProcessedOrders
FROM Employees e
WHERE e.EmployeeID IN (
	SELECT o.EmployeeID
	FROM Orders o
	GROUP BY o.EmployeeID
	HAVING COUNT(o.EmployeeID) = (
		SELECT MAX(maxCount) FROM (
			SELECT COUNT(*) maxCount
			FROM Orders oo
			GROUP BY oo.EmployeeID
		) maxCount
	)
)


-- 7. What are the most common ContactTitle in Customers?
SELECT DISTINCT ContactTitle 
FROM Customers
WHERE ContactTitle IN (
	SELECT ContactTitle
	FROM Customers c
	GROUP BY c.ContactTitle
	HAVING COUNT(c.ContactTitle) = (
		SELECT MAX(maxCount) 
		FROM (
			SELECT COUNT(*) maxCount
			FROM Customers cc
			GROUP BY cc.ContactTitle
		) AS maxCount
	)
)


-- 8. Is there a supplier that has the same name as a customer?
SELECT *
FROM Customers c
WHERE c.CompanyName IN(
	SELECT s.CompanyName
	FROM Suppliers s
)


-- 9. Give all the orders for which the ShipAddress is different from the CustomerAddress
SELECT o.*
FROM Orders o
WHERE o.ShipAddress NOT IN (
	SELECT c.Address
	FROM Customers c
	WHERE c.CustomerID = o.CustomerID
)
