-- 1. Give all employees that started working as an employee in the same year as Robert King

-- cte --> HireYear of Robert King




-- 2 Make a histogram of the number of orders per customer, so show how many times each number occurs. 
-- E.g.: 1 customer placed 1 order, 2 customers placed 2 orders, 7 customers placed 3 orders, etc. 

-- cte --> number of orders per customer

/*
nr	NumberOfCustomers
1	1
2	2
3	7
4	6
5	10

...

*/





-- 3. Give the customers of the Country in which most customers live
--> cte1: number of customers per country
--> cte2: maximum */

--CustomerID	CompanyName	Country
--GREAL	Great Lakes Food Market	USA
--HUNGC	Hungry Coyote Import Store	USA
--LAZYK	Lazy K Kountry Store	USA
--LETSS	Let's Stop N Shop	USA
--LONEP	Lonesome Pine Restaurant	USA
--OLDWO	Old World Delicatessen	USA
--RATTC	Rattlesnake Canyon Grocery	USA
--SAVEA	Save-a-lot Markets	USA
--SPLIR	Split Rail Beer & Ale	USA
--THEBI	The Big Cheese	USA
--THECR	The Cracker Box	USA
--TRAIH	Trail's Head Gourmet Provisioners	USA
--WHITC	White Clover Markets	USA




-- 4. Give all employees except for the eldest
--> birthdate of the eldest in subquery or cte

--employeeid	employeeName	birthdate
--1	Nancy Davolio	1978-12-08 00:00:00.000
--2	Andrew Fuller	1982-02-19 00:00:00.000
--3	Janet Leverling	1993-08-30 00:00:00.000
--4	Margaret Peacock	1967-09-19 00:00:00.000
--5	Steven Buchanan	1975-03-04 00:00:00.000
--6	Michael Suyama	1983-07-02 00:00:00.000
--7	Robert King	1980-05-29 00:00:00.000
--8	Laura Callahan	1978-01-09 00:00:00.000
--9	Anne Dodsworth	1986-01-27 00:00:00.000

-- Solution 1 (using Subqueries)


-- Solution 2 (using CTE's)



-- 5.  What is the total number of customers and suppliers?




-- 6. Give per title the eldest employee

--employeeid	title	min_birthdate
--8	Inside Sales Coordinator	1978-01-09 00:00:00.000
--5	Sales Manager	1975-03-04 00:00:00.000
--4	Sales Representative	1967-09-19 00:00:00.000
--2	Vice President, Sales	1982-02-19 00:00:00.000




-- 7. Give per title the employee that earns most
--employeeid	fullName	title	max_salary
--2	Andrew Fuller	Vice President, Sales	90000.00
--1	Nancy Davolio	Sales Representative	48000.00
--5	Steven Buchanan	Sales Manager	55000.00
--8	Laura Callahan	Inside Sales Coordinator	51000.00




-- 8. Give the titles for which the eldest employee is also the employee who earns most
--employeeid	title	min_birthdate	max_salary
--2	Vice President, Sales	1982-02-19 00:00:00.000	90000.00
--5	Sales Manager	1975-03-04 00:00:00.000	55000.00
--8	Inside Sales Coordinator	1978-01-09 00:00:00.000	51000.00




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
