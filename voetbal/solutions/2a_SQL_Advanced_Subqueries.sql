-- Wat was de grootste waarde voor het aantal speeldagen per seizoen?
-- Geef de seizoenen met het aantal speeldagen = maximum aantal speeldagen
--seizoen	aantal speeldagen
--1975/1976 	38
--1974/1975 	38
SELECT DISTINCT Seizoen, Speeldag
FROM Klassement
WHERE Speeldag = (SELECT MAX(Speeldag) FROM Klassement)


-- Geef de ploegen en seizoenen die het maximum aantal doelpunten scoorden in een seizoen
--seizoen	doelpuntenvoor	ploegnaam
--1984/1985 	100	RSC Anderlecht



-- Geef een overzicht van de ploegen met het grootste aantal verloren matchen in het klassement
--ploegnaam	seizoen	aantalverloren
--Beerschot	2021/2022 	26
--KSC Hasselt	1979/1980 	26


-- Geef een overzicht van de ploegen die altijd deelnamen aan de competitie
--ploegnaam	Aantal competities
--Club Brugge	64
--RSC Anderlecht	64
--Standard Luik	64


-- In hoeveel matchen werd de gelijkmaker in het laatste kwartier gescoord?
-- Merk op dat van sommige wedstrijden het doelpuntenverloop niet bekend is 
-- (=> het aantal wedstrijden met gelijk aantal doelpunten levert na JOIN met Doelpunt levert minder resultaten op)
-- 959



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



-- Hoeveel seizoenen werd een gegeven ploeg kampioen? Dit wil zeggen, stond de ploeg op positie 1 in het klassement op de laatste speeldag.
-- Hoe ga je de laatste speeldag van een seizoen berekenen?
-- Verander de inhoud van de variabele @ploegnaam van 'RSC Anderlecht' naar 'Anderlecht'. Hoe moet je de query aanpassen?
DECLARE @ploegnaam VARCHAR(255) = 'Anderlecht'



-- Geef de seizoenen waarbij de opgegeven ploeg (op de laatste speeldag) niet eindigde in de Top 4 van het klassement
--Seizoen	Positie
--1968/1969 	5
--1972/1973 	5
--1979/1980 	6
--2019/2020 	8
--2022/2023 	11
DECLARE @ploegnaam VARCHAR(255) = 'RSC Anderlecht'


