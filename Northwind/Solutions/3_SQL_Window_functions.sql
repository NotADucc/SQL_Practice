-- Exercises

-- Exercise 1
-- Create the following overview in which each customer gets a sequential number. 
-- The number is reset when the country changes
/*
country		rownum	CompanyName
Argentina	1		Cactus Comidas para llevar
Argentina	2		Océano Atlántico Ltda.
Argentina	3		Rancho grande
Austria		1		Ernst Handel
Austria		2		Piccolo und mehr
Belgium		1		Maison Dewey
Belgium		2		Suprêmes délices
Brazil		1		Comércio Mineiro
Brazil		2		Familia Arquibaldo
Brazil		3		Gourmet Lanchonetes
Brazil		4		Hanari Carnes
...
*/
SELECT Country, ROW_NUMBER() OVER (PARTITION BY Country ORDER BY Country) rownum, CompanyName
FROM Customers
ORDER BY Country


-- Exercise 2
-- We want to calculate the year over year perfomance for each product.
-- Step 1: First create an overview that shows for each productid the amount sold per year
/*
1	2016	125	
1	2017	304	
1	2018	399	
2	2016	226	
2	2017	435	
2	2018	396	
3	2016	30	
3	2017	190	
3	2018	108	
...
*/
SELECT od.ProductID, YEAR(o.OrderDate) AS YearSold, SUM(od.Quantity) AS TotalQuantity
FROM OrderDetails od
JOIN Orders o ON od.OrderID = o.OrderID
GROUP BY od.ProductID, YEAR(o.OrderDate)
ORDER BY ProductID


-- Step 2: Turn the previous query into a CTE. 
-- Now create an overview that shows for each productid the amount sold per year and for the previous year.
/*
1	2016	125	NULL
1	2017	304	125
1	2018	399	304
2	2016	226	NULL
2	2017	435	226
2	2018	396	435
3	2016	30	NULL
3	2017	190	30
3	2018	108	190
...
*/
WITH YearDetailsCTE AS(
	SELECT od.ProductID, YEAR(o.OrderDate) AS YearSold, SUM(od.Quantity) AS TotalQuantity
	FROM OrderDetails od
	JOIN Orders o ON od.OrderID = o.OrderID
	GROUP BY od.ProductID, YEAR(o.OrderDate)
),
YearDetailsWithComparisionCTE AS(
	SELECT x.ProductID, x.YearSold, x.TotalQuantity, LAG(x.TotalQuantity) OVER (PARTITION BY x.ProductId ORDER BY x.ProductID, x.YearSold) AS TotalQuantityPrev
	FROM YearDetailsCTE x
)
SELECT *
FROM YearDetailsWithComparisionCTE
ORDER BY ProductID


-- Step 3: Use a CTE and the previous SQL Query to calculate the year over year performance for each productid. 
-- If the amountPreviousYear is NULL, then the year over year performance becomes N/A. Use the function IFNULL

/*
1	2016	125	NULL	N/A
1	2017	304	125	143.20%
1	2018	399	304	31.25%
2	2016	226	NULL	N/A
2	2017	435	226	92.48%
2	2018	396	435	-8.97%
3	2016	30	NULL	N/A
3	2017	190	30	533.33%
3	2018	108	190	-43.16%
...
*/
WITH YearDetailsCTE AS(
	SELECT od.ProductID, YEAR(o.OrderDate) AS YearSold, SUM(od.Quantity) AS TotalQuantity
	FROM OrderDetails od
	JOIN Orders o ON od.OrderID = o.OrderID
	GROUP BY od.ProductID, YEAR(o.OrderDate)
),
YearDetailsWithComparisionCTE AS(
	SELECT x.ProductID, x.YearSold, x.TotalQuantity, LAG(x.TotalQuantity) OVER (PARTITION BY x.ProductId ORDER BY x.ProductID, x.YearSold) AS TotalQuantityPrev
	FROM YearDetailsCTE x
)
SELECT *, ISNULL(FORMAT((TotalQuantity * 1.00 / TotalQuantityPrev - 1), 'P2'), 'N/A') AS YearOverYearPerformance
FROM YearDetailsWithComparisionCTE
ORDER BY ProductID

-- Exercise 3
-- Which is the most popular shipper
-- Step 1: Use a CTE and add DENSE_RANK
-- Step 2: FILTER on DENSE_RANK = 1

-- ShipperID	CompanyName	ShipVia	NumberOfOrders	DENSE_RANK
-- 2	United Package	2	326	1
WITH DenseRanks AS(
	SELECT ShipVia, COUNT(ShipVia) AS NumberOfOrders, DENSE_RANK() OVER (ORDER BY COUNT(ShipVia) DESC) AS 'Rank'
	FROM Orders
	GROUP BY ShipVia
)
SELECT s.ShipperID, s.CompanyName, dr.ShipVia, dr.NumberOfOrders, dr.Rank AS DENSE_RANK
FROM DenseRanks dr
JOIN Shippers s ON dr.ShipVia = s.ShipperID
WHERE dr.Rank = 1

-- Exercise 4
-- Which is the TOP 3 of countries in which most customers live?
-- Step 1: Use a CTE and add DENSE_RANK
-- Step 2: FILTER on DENSE_RANK
-- Idem as the previous exercise

--Country	NumberOfCustomers	DENSE_RANK
--USA	13	1
--France	11	2
--Germany	11	2
--Brazil	9	3
WITH DenseRanks AS(
	SELECT 
		Country, 
		COUNT(Country) AS NumberOfCustomers,
		DENSE_RANK() OVER(ORDER BY COUNT(Country) DESC) AS DENSE_RANK
	FROM Customers
	GROUP BY Country
)
SELECT *
FROM DenseRanks
WHERE DENSE_RANK <= 3



-- Exercise 5: 
-- Imagine there is a bonussystem for all the employees: the best employee gets 10 000EUR bonus, 
-- the second one 5000 EUR, the third one 3333 EUR, …
-- Let's calculate the bonus for each employee, based on the revenue per year per employee
-- Step 1: First create an overview of the revenue (unitprice * quantity) per year per employeeid
/*
1	2016	38789,00
1	2017	97533,58
1	2018	65821,13
2	2016	22834,70
2	2017	74958,60
2	2018	79955,96
3	2016	19231,80
3	2017	111788,61
3	2018	82030,89
4	2016	53114,80
4	2017	139477,70
4	2018	57594,95
...
*/
WITH AnualRevenuePerEmployee AS(
	SELECT o.EmployeeID, YEAR(o.OrderDate) AS OrderYear, SUM(od.Quantity * od.UnitPrice) AS TotalRevenue
	FROM Orders o
	JOIN OrderDetails od ON o.OrderID = od.OrderID
	GROUP BY EmployeeID, YEAR(OrderDate)
)
SELECT *
FROM AnualRevenuePerEmployee
ORDER BY EmployeeID, OrderYear



-- Step 2: Now add a ranking per year per employeeid
/*
4	2016	53114,80	1
1	2016	38789,00	2
8	2016	23161,40	3
2	2016	22834,70	4
5	2016	21965,20	5
3	2016	19231,80	6
7	2016	18104,80	7
6	2016	17731,10	8
9	2016	11365,70	9
...
*/
WITH AnualRevenuePerEmployee AS(
	SELECT o.EmployeeID, YEAR(o.OrderDate) AS OrderYear, SUM(od.Quantity * od.UnitPrice) AS TotalRevenue
	FROM Orders o
	JOIN OrderDetails od ON o.OrderID = od.OrderID
	GROUP BY EmployeeID, YEAR(OrderDate)
),
AnualRevenuePerEmployeeRanks AS(
	SELECT *, RANK() OVER(PARTITION BY OrderYear ORDER BY OrderYear, TotalRevenue DESC) AS TotalRevenueRank
	FROM AnualRevenuePerEmployee
)
SELECT *
FROM AnualRevenuePerEmployeeRanks


-- Step 3: Imagine there is a bonussystem for all the employees: the best employee gets 10 000EUR bonus, 
-- the second one 5000 EUR, the third one 3333 EUR, …

/*
4	2016	53114,80	10000
1	2016	38789,00	5000
8	2016	23161,40	3333
2	2016	22834,70	2500
5	2016	21965,20	2000
3	2016	19231,80	1666
7	2016	18104,80	1428
6	2016	17731,10	1250
9	2016	11365,70	1111
...
*/




-- Exercise 6 
-- Calculate for each month the percentage difference between the revenue for this month and the previous month
/*
2016	7	30192,10	NULL	NULL
2016	8	26609,40	30192,10	-11.86%
2016	9	27636,00	26609,40	3.85%
2016	10	41203,60	27636,00	49.09%
2016	11	49704,00	41203,60	20.63%
2016	12	50953,40	49704,00	2.51%
2017	1	66692,80	50953,40	30.88%
2017	2	41207,20	66692,80	-38.21%
2017	3	39979,90	41207,20	-2.97%
2017	4	55699,39	39979,90	39.31%
2017	5	56823,70	55699,39	2.01%
2017	6	39088,00	56823,70	-31.21%
2017	7	55464,93	39088,00	41.89%
2017	8	49981,69	55464,93	-9.88%
2017	9	59733,02	49981,69	19.50%
*/

-- Step 1: calculate the revenue per year and per month


-- Step 2: Add an extra column for each row with the revenue of the previous month


-- Step 3: Calculate the percentage difference between this month and the previous month






/* EXTRA */
---------------
-- Give the cumulative number of Orders for each customer for each year
/*
ALFKI	2017	3
ALFKI	2018	6
ANATR	2016	1
ANATR	2017	3
ANATR	2018	4
ANTON	2016	1
ANTON	2017	6
ANTON	2018	7
...
*/



-- Give the cumulative number of Suppliers for each country
/*
7	Pavlova, Ltd.				Australia	1
24	G'day, Mate					Australia	2
10	Refrescos Americanas LTDA	Brazil	1
25	Ma Maison					Canada	1
29	Forêts d'érables			Canada	2
21	Lyngbysild					Denmark	1
23	Karkki Oy					Finland	1
18	Aux joyeux ecclésiastiques	France	1
27	Escargots Nouveaux			France	2
28	Gai pâturage				France	3
...
*/







-- Give for each customer for each year the number of orders and the total number over orders over all years using PARTITION BY
/*
ALFKI	2017	3	6
ALFKI	2018	3	6
ANATR	2016	1	4
ANATR	2017	2	4
ANATR	2018	1	4
ANTON	2016	1	7
ANTON	2017	5	7
ANTON	2018	1	7
AROUT	2016	2	13
AROUT	2017	7	13
AROUT	2018	4	13
BERGS	2016	3	18
BERGS	2017	10	18
BERGS	2018	5	18
...
*/





-- Give the relative number of Customers for each country using PARTITION BY
/*
Argentina	3.30%
Austria	2.20%
Belgium	2.20%
Brazil	9.89%
Canada	3.30%
Denmark	2.20%
Finland	2.20%
France	12.09%
Germany	12.09%
Ireland	1.10%
*/

-- Step 1: Calculate for each country the number of customers for this country and the total number of customers using PARTITION BY
-- Step 2: Calculate the relative number of customers per country

-- Alternative??

