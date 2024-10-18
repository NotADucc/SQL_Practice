/* We vragen ons af of er veel kans is dat een ploeg die na 10 speeldagen in de Top 6 van het klassement
staat, op de laatste speeldag ook nog in de Top 6 van het klassement zal staan.
Creëer een CTE die alle records bevat van het klassement op speeldag 10 en op de laatste speeldag.
Hiervoor kan je gebruik maken van een gecorreleerde subquery of een UNION van de records op speeldag 10 en de records op de laatste speeldag.

seizoen	speeldag	positie	stamnummer
1960/1961 	10	1	16
1960/1961 	10	2	4
1960/1961 	10	3	90
1960/1961 	10	4	35
1960/1961 	10	5	2
...
1960/1961 	30	1	16
1960/1961 	30	2	4
1960/1961 	30	3	35

*/
WITH cte_max_speeldag AS (
	SELECT Seizoen, MAX(Speeldag) speeldag
	FROM Klassement
	GROUP BY Seizoen
),
cte_10 AS (
	SELECT Seizoen, speeldag, Positie, Stamnummer
	FROM Klassement k
	WHERE Speeldag = 10
),
cte_max AS (
	SELECT k.Seizoen, k.speeldag, Positie, Stamnummer
	FROM Klassement k
	JOIN cte_max_speeldag m ON k.Seizoen = m.Seizoen AND k.Speeldag = m.speeldag
),
cte_union AS (
	SELECT *
	FROM cte_10
	UNION
	SELECT *
	FROM cte_max
)
SELECT *
FROM cte_union
GO

/*
Creëer een CTE waarbij de positie op de laatste speeldag naast de positie op speeldag 10 staat.

stamnummer	seizoen	speeldag	positie	positie_laatste_speeldag
1	1960/1961 	10	13	8
1	1960/1961 	30	8	NULL
2	1960/1961 	10	5	5
2	1960/1961 	30	5	NULL
3	1960/1961 	10	12	11
3	1960/1961 	30	11	NULL

*/

WITH cte_max_speeldag AS (
	SELECT Seizoen, MAX(Speeldag) speeldag
	FROM Klassement
	GROUP BY Seizoen
),
cte_10 AS (
	SELECT Seizoen, speeldag, Positie, Stamnummer
	FROM Klassement k
	WHERE Speeldag = 10
),
cte_max AS (
	SELECT k.Seizoen, k.speeldag, Positie, Stamnummer
	FROM Klassement k
	JOIN cte_max_speeldag m ON k.Seizoen = m.Seizoen AND k.Speeldag = m.speeldag
),
cte_union AS (
	SELECT *
	FROM cte_10
	UNION
	SELECT *
	FROM cte_max
)
SELECT 
	Stamnummer, 
	Seizoen, 
	Speeldag, 
	Positie, 
	LEAD(Positie) OVER (PARTITION BY stamnummer, seizoen ORDER BY speeldag) as positie_laatste_speeldag
FROM cte_union
GO
/*
Creëer een CTE met 2 extra kolommen in_top_6_speeldag_10 en in_top_6_laatste_speeldag

stamnummer	seizoen	speeldag	positie	positie_laatste_speeldag	in_top_6_speeldag_10	in_top_6_laatste_speeldag
1	1960/1961 	10	13	8	Geen Top 6	Geen Top 6
2	1960/1961 	10	5	5	Top 6	Top 6
3	1960/1961 	10	12	11	Geen Top 6	Geen Top 6
4	1960/1961 	10	2	2	Top 6	Top 6

*/

WITH cte_max_speeldag AS (
	SELECT Seizoen, MAX(Speeldag) speeldag
	FROM Klassement
	GROUP BY Seizoen
),
cte_10 AS (
	SELECT Seizoen, speeldag, Positie, Stamnummer
	FROM Klassement k
	WHERE Speeldag = 10
),
cte_max AS (
	SELECT k.Seizoen, k.speeldag, Positie, Stamnummer
	FROM Klassement k
	JOIN cte_max_speeldag m ON k.Seizoen = m.Seizoen AND k.Speeldag = m.speeldag
),
cte_union AS (
	SELECT *
	FROM cte_10
	UNION
	SELECT *
	FROM cte_max
),
cte_lead AS (
	SELECT 
		Stamnummer, 
		Seizoen, 
		Speeldag, 
		Positie, 
		LEAD(Positie) OVER (PARTITION BY stamnummer, seizoen ORDER BY speeldag) as positie_laatste_speeldag
	FROM cte_union
)
SELECT *,
	CASE WHEN Positie <= 6 THEN 'Top 6' ELSE 'Geen top 6' END 'top_6_speeldag_10',
	CASE WHEN positie_laatste_speeldag <= 6 THEN 'Top 6' ELSE 'Geen top 6' END 'top_6_speeldag_laatste'
FROM cte_lead
WHERE positie_laatste_speeldag IS NOT NULL
GO

/*

Maak nu het onderstaande overzicht
in_top_6_speeldag_10	in_top_6_laatste_speeldag	aantal_keer
Top 6					Geen Top 6					103
Geen Top 6				Geen Top 6					614
Top 6					Top 6						281
Geen Top 6				Top 6						103
*/

WITH cte_max_speeldag AS (
	SELECT Seizoen, MAX(Speeldag) speeldag
	FROM Klassement
	GROUP BY Seizoen
),
cte_10 AS (
	SELECT Seizoen, speeldag, Positie, Stamnummer
	FROM Klassement k
	WHERE Speeldag = 10
),
cte_max AS (
	SELECT k.Seizoen, k.speeldag, Positie, Stamnummer
	FROM Klassement k
	JOIN cte_max_speeldag m ON k.Seizoen = m.Seizoen AND k.Speeldag = m.speeldag
),
cte_union AS (
	SELECT *
	FROM cte_10
	UNION
	SELECT *
	FROM cte_max
),
cte_lead AS (
	SELECT 
		Stamnummer, 
		Seizoen, 
		Speeldag, 
		Positie, 
		LEAD(Positie) OVER (PARTITION BY stamnummer, seizoen ORDER BY speeldag) as positie_laatste_speeldag
	FROM cte_union
),
cte_top_6 AS (
	SELECT *,
		CASE WHEN Positie <= 6 THEN 'Top 6' ELSE 'Geen top 6' END 'top_6_speeldag_10',
		CASE WHEN positie_laatste_speeldag <= 6 THEN 'Top 6' ELSE 'Geen top 6' END 'top_6_speeldag_laatste'
	FROM cte_lead
	WHERE positie_laatste_speeldag IS NOT NULL
)
SELECT top_6_speeldag_10, top_6_speeldag_laatste, COUNT(*)
FROM cte_top_6
GROUP by top_6_speeldag_10, top_6_speeldag_laatste
GO