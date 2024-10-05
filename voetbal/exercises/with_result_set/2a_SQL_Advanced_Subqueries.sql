-- 1.
-- Wat was de grootste waarde voor het aantal speeldagen per seizoen?
--seizoen	aantal speeldagen
--1975/1976 	38
--1974/1975 	38
-- TIP
-- Bereken in een subquery de maximum waarde voor het aantal speeldagen
-- Geef vervolgens de seizoenen met het aantal speeldagen = maximum aantal speeldagen


-- 2.
-- Geef de ploegen en seizoenen die het maximum aantal doelpunten scoorden in een seizoen
--seizoen	doelpuntenvoor	ploegnaam
--1984/1985 	100	RSC Anderlecht
-- TIP
-- Analoog aan het voorgaande
-- Bereken in een subquery de maximum waarde voor het aantal doelpuntenvoor
-- Geef vervolgens de seizoenen en ploegen met doelpuntenvoor = maximum aantal doelpuntenvoor


-- 3.
-- Geef een overzicht van de ploegen met het grootste aantal verloren matchen in het klassement
--ploegnaam	seizoen	aantalverloren
--Beerschot	2021/2022 	26
--KSC Hasselt	1979/1980 	26
-- TIP
-- Analoog aan het voorgaande
-- Bereken in een subquery de maximum waarde voor aantalverloren
-- Geef vervolgens de seizoenen en ploegen met aantalverloren = maximum aantalverloren


-- 4.
-- Geef een overzicht van de ploegen die altijd deelnamen aan de competitie
--ploegnaam	Aantal competities
--Club Brugge	64
--RSC Anderlecht	64
--Standard Luik	64
-- TIP
-- Bereken het aantal seizoenen 
-- Bereken per ploeg het aantal seizoenen
-- Combineer de beide


-- 5.
-- In hoeveel matchen werd de gelijkmaker in het laatste kwartier gescoord?
-- Merk op dat van sommige wedstrijden het doelpuntenverloop niet bekend is 
-- (=> het aantal wedstrijden met gelijk aantal doelpunten levert na JOIN met Doelpunt minder resultaten op)
-- 959
-- TIP
-- Geef enkel de wedstrijden die eindigden op gelijkstand 
-- Bereken het aantal doelpunten in het laatste kwartier 
-- Maak gebruik van een gecorreleerde subquery


-- 6.
-- Zijn er ploegen die in de helft van het seizoen nog géén enkele wedstrijd verloren hadden?
--seizoen	stamnummer	ploegnaam	aantalverloren
--1971/1972 	3	Club Brugge	0
--1974/1975 	47	RWD Molenbeek	0
--1984/1985 	35	RSC Anderlecht	0
--1986/1987 	2300	KSK Beveren	0
--1987/1988 	1	Royal Antwerp FC	0
--1989/1990 	25	KV Mechelen	0
--1997/1998 	3	Club Brugge	0
--2000/2001 	35	RSC Anderlecht	0
--2007/2008 	16	Standard Luik	0
--2018/2019 	322	KRC Genk	0
--2019/2020 	3	Club Brugge	0
-- TIP
-- De helft van het seizoen is afhankelijk van het aantal speeldagen
-- Bijvoobeeld
-- 30 speeldagen => helft van het seizoen = speeldag 15
-- 34 speeldagen => helft van het seizoen = speeldag 17
-- Bereken dus (de helft van) het aantal speeldagen per seizoen in een subquery
-- Maak gebruik van een gecorreleerde subquery


-- 7.
-- Hoeveel seizoenen werd een gegeven ploeg kampioen? 
-- Dit wil zeggen, stond de ploeg op positie 1 in het klassement op de laatste speeldag.
-- Verander de inhoud van de variabele @ploegnaam van 'RSC Anderlecht' naar 'Anderlecht'. Hoe moet je dan de query aanpassen?
-- TIP
-- Analoog als voorgaande
-- Bereken het aantal speeldagen per seizoen in een subquery
-- Maak gebruik van een gecorreleerde subquery
DECLARE @ploegnaam VARCHAR(255) = 'Anderlecht'


-- 8.
-- Geef de seizoenen waarbij de opgegeven ploeg (op de laatste speeldag) niet eindigde in de Top 4 van het klassement
--Seizoen	Positie
--1968/1969 	5
--1972/1973 	5
--1979/1980 	6
--2019/2020 	8
--2022/2023 	11
-- TIP
-- Analoog als voorgaande
-- Bereken het aantal speeldagen per seizoen in een subquery
-- Maak gebruik van een gecorreleerde subquery
DECLARE @ploegnaam VARCHAR(255) = 'RSC Anderlecht'


