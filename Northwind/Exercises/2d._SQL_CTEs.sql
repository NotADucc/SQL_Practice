/* Exercises */


-- 1. Give all employees that started working as an employee in the same year as Robert King
-- cte --> HireYear of Robert King



-- 2 Make a histogram of the number of orders per customer, so show how many times each number occurs. 
-- E.g.: 1 customer placed 1 order, 2 customers placed 2 orders, 7 customers placed 3 orders, etc. 
-- cte --> number of orders per customer


-- 3. Give the customers of the Country in which most customers live
--> cte1: number of customers per country
--> cte2: maximum */


-- 4. Give all employees except for the eldest
--> birthdate of the eldest in subquery or cte
-- Solution 1 (using Subqueries)


-- Solution 2 (using CTE's)


-- 5.  What is the total number of customers and suppliers?


-- 6. Give per title the eldest employee
--refrain from using window functions


-- 7. Give per title the employee that earns most
--refrain from using window functions


-- 8. Give the titles for which the eldest employee is also the employee who earns most
--refrain from using window functions

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

