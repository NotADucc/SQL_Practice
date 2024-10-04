-- Exercises

-- Exercise 1
-- Create the following overview in which each customer gets a sequential number. 
-- The number is reset when the country changes



-- Exercise 2
-- We want to calculate the year over year perfomance for each product.
-- Step 1: First create an overview that shows for each productid the amount sold per year



-- Step 2: Turn the previous query into a CTE. 
-- Now create an overview that shows for each productid the amount sold per year and for the previous year.



-- Step 3: Use a CTE and the previous SQL Query to calculate the year over year performance for each productid. 
-- If the amountPreviousYear is NULL, then the year over year performance becomes N/A. Use the function IFNULL



-- Exercise 3
-- Which is the most popular shipper
-- Step 1: Use a CTE and add DENSE_RANK
-- Step 2: FILTER on DENSE_RANK = 1


-- Exercise 4
-- Which is the TOP 3 of countries in which most customers live?
-- Step 1: Use a CTE and add DENSE_RANK
-- Step 2: FILTER on DENSE_RANK
-- Idem as the previous exercise



-- Exercise 5: 
-- Imagine there is a bonussystem for all the employees: the best employee gets 10 000EUR bonus, 
-- the second one 5000 EUR, the third one 3333 EUR, …
-- Let's calculate the bonus for each employee, based on the revenue per year per employee
-- Step 1: First create an overview of the revenue (unitprice * quantity) per year per employeeid




-- Step 2: Now add a ranking per year per employeeid



-- Step 3: Imagine there is a bonussystem for all the employees: the best employee gets 10 000EUR bonus, 
-- the second one 5000 EUR, the third one 3333 EUR, …



-- Exercise 6 
-- Calculate for each month the percentage difference between the revenue for this month and the previous month
-- Step 1: calculate the revenue per year and per month


-- Step 2: Add an extra column for each row with the revenue of the previous month


-- Step 3: Calculate the percentage difference between this month and the previous month





/* EXTRA */
---------------
-- Give the cumulative number of Orders for each customer for each year


-- Give the cumulative number of Suppliers for each country


-- Give for each customer for each year the number of orders and the total number over orders over all years using PARTITION BY


-- Give the relative number of Customers for each country using PARTITION BY
-- Step 1: Calculate for each country the number of customers for this country and the total number of customers using PARTITION BY


-- Step 2: Calculate the relative number of customers per country



-- Alternative??
