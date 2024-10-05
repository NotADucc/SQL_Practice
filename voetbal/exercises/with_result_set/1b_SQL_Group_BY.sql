-- 1.
-- Een aantal statements om VoetbalDB te leren kennen
-- Hoeveel wedstrijden zitten er in de databank?
-- 18630



-- 2.
-- Van hoeveel wedstrijden zijn er doelpunten beschikbaar in de databank?
-- 14258



-- 3.
-- Wat is het eerste seizoen in de databank?
-- 1960/1961



-- 4.
-- Wat is het laatste seizoen in de databank
-- 2023/2024



-- 5.
-- Geef het maximum aantal doelpunten dat ooit gescoord werd door een ploeg gedurende een seizoen
-- 100



-- 6.
-- Welk soort wedstrijden zijn er?
-- Regulier / Playoff_1 / Playoff_2



-- 7.
-- Hoeveel reguliere / Playoff_1 / Playoff_2 wedstrijden zitten er in de databank?
-- Playoff_1	336
-- Regulier	17906
-- Playoff_2	388



-- 8.
-- Het aantal speeldagen verschilt per seizoen. Geef het aantal speeldagen per seizoen.
-- 1960/1961 	30
-- ...
-- 1973/1974 	30
-- 1974/1975 	38
-- 1975/1976 	38
-- 1976/1977 	34
-- ...



-- 9.
-- Geef het aantal matchen waarbij de thuisploeg won met meer dan 2 doelpunten verschil 
-- 2429



-- 10.
-- Hoe vaak eindigt een reguliere wedstrijd op 0-0
-- 1502



-- 11.
-- Hoe vaak eindigt een wedstrijd op gelijkstand?
-- 4807



-- 12.
-- Als de ploegnaam van een club wordt gegeven, hoeveel jaar nam die ploeg deel aan de competitie?
-- 14
DECLARE @ploegnaam VARCHAR(255) = 'KV Oostende'


-- 13.
-- In hoeveel wedstrijden bedroeg het totaal aantal doelpunten meer dan 10 (10 exclusief)?
-- 16



-- 14.
-- Maak een overzicht van hoe vaak elke eindstand voorkomt in de databank
--Eindstand	Aantal
--1:1	2135
--1:0	1742
--0:0	1544
--2:0	1524
--2:1	1507
--0:1	1112
--1:2	1010
--3:1	996
--2:2	963
--3:0	853



