-- We vragen ons af of er in het begin van de competitie opvallend meer
-- doelpunten worden gescoord dan op het einde van de competitie
-- Bereken per speeldag het totaal aantal doelpunten.
-- Creëer een cte met het aantal doelpuntenVoor en het aantal doelpuntenVoor van de vorige speeldag in het klassement (per ploeg)
-- Creëer een cte om het verschil tussen de beide berekenen
-- Bereken per speeldag het totaal aantal doelpunten. Doe dit enkel voor de eerste 30 speeldagen.
--speeldag	Totaal
--23	1438
--29	1534
--9	1503
--15	1522
--3	1523
--26	1431
--12	1463






-- Geef de Top 5 van eindscores die het vaakst voorkomen
-- Maak een CTE die de eindscores bevat
-- Bereken hoe vaak elke eindscore voorkomt
-- Geef de Top 5

--uitslag	aantal_wedstrijden	ranking
--1:1		2135				1
--1:0		1742				2
--0:0		1544				3
--2:0		1524				4
--2:1		1507				5







-- Geef de Top 5 van ploegen die het vaakst kampioen werden
-- Bereken (mbv CTE's) per seizoen wie kampioen werd (zie de oefeningen op CTE's)
-- Bereken (mbv een CTE) vervolgens hoe vaak elke ploeg kampioen werd
-- Voeg (mbv een CTE) een ranking toe
-- Maak de Top 5


--ploegnaam	aantal_keer_kampioen	ranking
--RSC Anderlecht	27					1
--Club Brugge		17					2
--Standard Luik		9					3
--KRC Genk			4					4
--KSK Beveren		2					5
--Union Saint-Gilloise	2				5








/*
In deze oefening gaan we zelf het klassement berekenen vertrekkend van Wedstrijden.
Creëer een CTE cte_1 die een kolom seizoen toevoegt aan Wedstrijden. (zie oefeningen CTE's)
Creëer op basis van cte_1, een nieuwe cte_2 die enkel de wedstrijden geeft waaraan de opgegeven ploeg deelnam in het opgegeven seizoen
Creëer op basis van cte_2, een nieuwe cte_3 met de volgende extra kolommen:
- Een kolom speeldag. Maak gebruik van een window function.
- Een kolom isGewonnen: 1 indien de opgegeven ploeg heeft gewonnen, anders 0. Maak gebruik van een CASE stament. 
- Een kolom isGelijk: 1 indien gelijkspel, anders 0. Maak gebruik van een CASE stament. 
- Een kolom isVerloren: 1 indien de geselecteerde ploeg is verloren, anders 0. Maak gebruik van een CASE stament. 
- Een kolom doelpuntenVoor: het aantal doelpunten dat de geselecteerde ploeg heeft gescoord. Maak gebruik van een CASE stament. 
- Een kolom doelpuntenTegen: het aantal doelpunten dat de geselecteerde ploeg binnen heeft gekregen. Maak gebruik van een CASE stament. 
Creëer op basis van cte_3, een nieuwe cte_4 met de volgende extra kolommen:
- Een kolom aantalGewonnen: het totaal aantal gewonnen matchen tot nog toe
- Een kolom aantalGelijk: het totaal aantal gelijke matchen tot nog toe
- Een kolom aantalVerloren: het totaal aantal verloren matchen tot nog toe
- Een kolom doelpuntenVoor: het totaal aantal gescoorde doelpunten tot nog toe
- Een kolom doelpuntenTegen: het totaal aantal doelpunten tegentot nog toe
Creëer op basis van cte_4 een overzicht met bovendien de extra kolom driePunten: het aantal gewonnen matchen * 3 + het aantal gelijke matchen * 1
*/

-- Het resultaat voor RSC Anderlecht in 2022/2023
--speeldag	aantalGewonnen	aantalGelijk	aantalVerloren	doelpuntenVoor	doelpuntenTegen	driepunten
--1	1	0	0	2	0	3
--2	1	0	1	2	1	3
--3	2	0	1	5	2	6
--4	3	0	1	8	2	9
--5	3	0	2	8	3	9
--6	3	0	3	9	5	9
--7	3	1	3	11	7	10
--8	3	1	4	12	9	10
--9	4	1	4	16	10	13
--10	4	1	5	16	11	13
--11	5	1	5	19	12	16
--12	5	1	6	19	13	16
--13	5	1	7	21	16	16
--14	5	1	8	21	21	16
--15	6	1	8	25	23	19
--16	6	2	8	25	23	20
--17	6	2	9	25	25	20
--18	7	2	9	26	25	23
--19	7	2	10	27	28	23
--20	7	3	10	28	29	24
--21	7	3	11	30	32	24
--22	8	3	11	31	32	27
--23	8	4	11	31	32	28
--24	9	4	11	33	32	31
--25	10	4	11	36	33	34
--26	10	5	11	38	35	35
--27	10	6	11	40	37	36
--28	10	6	12	40	38	36
--29	11	6	12	42	38	39
--30	12	6	12	44	38	42
--31	13	6	12	45	38	45
--32	13	7	12	45	38	46
--33	13	7	13	47	43	46
--34	13	7	14	49	46	46


DECLARE @seizoen VARCHAR(10) = '2022/2023';
DECLARE @stamnummer INT = (SELECT stamnummer FROM ploeg WHERE ploegnaam = 'RSC Anderlecht');







/* Uit de oefeningen op CTE's weten we dat de thuisploeg een thuisvoordeel heeft:

--WieWint	procentueel deel
--Gelijk	0.258024691358
--Thuis		0.481910896403
--Uit		0.260064412238

We vragen ons af hoe die cijfers er zouden uit zien indien de thuisploeg in de Top 5 staat op die speeldag.
We willen dus weten hoe goed de thuisploeg scoort als die op de speeldatum in de Top 5 staat van het klassement.
De positie in het klassement is echter de positie van die ploeg ná het afwerken van die speeldag.
Door de positie van de vorige speeldag te nemen, kennen we de positie van de ploeg op het moment van het spelen van de wedstrijd.

Creëer een CTE die voor elke wedstrijd het resultaat geeft voor de thuisploeg: Gewonnen / Gelijk / Verloren
Creëer een CTE die het seizoen toevoegt aan Wedstrijd
Creëer een CTE die de speeldag toevoegt aan Wedstrijd
Creëer een CTE die de positie in het klassement toevoegt op die speeldag in dat seizoen voor de thuisploeg
Creëer een CTE die de vorige positie in het klassement toevoegt, dit is de positie van de thuisploeg op het moment van het spelen van de wedstrijd
Tel hoe vaak de thuisploeg wint / gelijk speelt / verliest indien de thuisploeg tot de Top 5 behoort op het moment van het spelen van de wedstrijd.

resultaat	aantal
Gewonnen	3082
Verloren	895
Gelijk		1238

*/

