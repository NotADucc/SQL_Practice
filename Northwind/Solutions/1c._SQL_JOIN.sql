-- 1. Which suppliers (SupplierID and CompanyName) deliver Dairy Products? 
SELECT DISTINCT s.SupplierID, s.CompanyName
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
JOIN Categories c ON p.CategoryID = c.CategoryID
WHERE c.CategoryName = 'Dairy Products'

--OR

SELECT DISTINCT s.SupplierID, s.CompanyName
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
JOIN Categories c ON p.CategoryID = c.CategoryID AND c.CategoryName = 'Dairy Products'

-- 2. Give for each supplier the number of orders that contain products of that supplier. 
SELECT s.SupplierID, s.CompanyName, COUNT(DISTINCT od.OrderID) AS NrOfOrders
FROM Suppliers s
JOIN Products p ON s.SupplierID = p.SupplierID
JOIN OrderDetails od ON p.ProductID = od.ProductID
GROUP BY s.SupplierID, s.CompanyName
ORDER BY s.CompanyName


-- 3. What’s for each category the lowest UnitPrice? Show category name and unit price. 
SELECT c.CategoryName, MIN(p.UnitPrice) AS 'Minimum Price'
FROM Categories c
JOIN Products p ON c.CategoryID = p.CategoryID
GROUP BY c.CategoryName

-- 4. Give for each ordered product: productname, the least (columnname 'Min amount ordered') and the most ordered (columnname 'Max amount ordered'). Order by productname.
SELECT p.ProductName, MIN(Quantity) AS 'Min amount ordered', MAX(Quantity) AS 'Max amount ordered'
FROM OrderDetails od
JOIN Products p ON od.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY p.ProductName

-- 5. Give a summary for each employee with orderID, employeeID and employeename.
-- Make sure that the list also contains employees who don’t have orders yet.
SELECT e.EmployeeID, CONCAT(e.FirstName, ' ', e.LastName) AS Name, o.OrderID
FROM Employees e
LEFT JOIN Orders o ON o.EmployeeID = e.EmployeeID