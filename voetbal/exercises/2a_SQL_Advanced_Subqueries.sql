-- 1.
-- Wat was de grootste waarde voor het aantal speeldagen per seizoen?
--seizoen	aantal speeldagen


-- 2.
-- Geef de ploegen en seizoenen die het maximum aantal doelpunten scoorden in een seizoen
--seizoen	doelpuntenvoor	ploegnaam


-- 3.
-- Geef een overzicht van de ploegen met het grootste aantal verloren matchen in het klassement
--ploegnaam	seizoen	aantalverloren


-- 4.
-- Geef een overzicht van de ploegen die altijd deelnamen aan de competitie
--ploegnaam	Aantal competities


-- 5.
-- In hoeveel matchen werd de gelijkmaker in het laatste kwartier gescoord?
-- Merk op dat van sommige wedstrijden het doelpuntenverloop niet bekend is 
-- (=> het aantal wedstrijden met gelijk aantal doelpunten levert na JOIN met Doelpunt minder resultaten op)


-- 6.
-- Zijn er ploegen die in de helft van het seizoen nog géén enkele wedstrijd verloren hadden?
--seizoen	stamnummer	ploegnaam	aantalverloren


-- 7.
-- Hoeveel seizoenen werd een gegeven ploeg kampioen? 
-- Dit wil zeggen, stond de ploeg op positie 1 in het klassement op de laatste speeldag.
-- Verander de inhoud van de variabele @ploegnaam van 'RSC Anderlecht' naar 'Anderlecht'. Hoe moet je dan de query aanpassen?
DECLARE @ploegnaam VARCHAR(255) = 'Anderlecht'


-- 8.
-- Geef de seizoenen waarbij de opgegeven ploeg (op de laatste speeldag) niet eindigde in de Top 4 van het klassement
--Seizoen	Positie
DECLARE @ploegnaam VARCHAR(255) = 'RSC Anderlecht'


