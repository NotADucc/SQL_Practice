-- 1.
-- Creëer het onderstaande overzicht van een geselecteerde ploeg voor een geselecteerd seizoen.
--Speeldag	Positie
DECLARE @ploegnaam VARCHAR(255) = 'Club Brugge'
DECLARE @seizoen VARCHAR(10) = '2014/2015'


-- 2.
-- Geef de namen van de ploegen en de seizoenen die op de 10de speeldag nog geen enkele match hadden gewonnen
--seizoen	ploegnaam


-- 3.
-- Als de ploegnamen van 2 clubs worden gegeven, bereken dan hoe vaak de beide ploegen scoorden in de vroegere duels.
DECLARE @ploegnaam1 VARCHAR(255) = 'Club Brugge'
DECLARE @ploegnaam2 VARCHAR(255) = 'Cercle Brugge'


-- 4.
-- Bij het wedden in de Play Offs zou je eventueel kunnen rekening houden met hoeveel ervaring een club heeft met spelen van de Play Offs
-- Als de ploegnaam van een club gegeven wordt, laat dan zien hoeveel seizoenen een club in Play Off 1 en in Play Off 2 heeft gespeeld tot nu toe.
DECLARE @ploegnaam VARCHAR(255) = 'Club Brugge'


-- 5.
-- Geef de wedstrijden (wedstrijdID, speeldatum, ploegnaam1, ploegnaam2, eindstandthuis, eindstanduit) 
-- waar het totaal aantal doelpunten meer dan 10 bedraagt (10 exclusief).
--wedstrijdID	speeldatum	ploegnaam	ploegnaam	eindstandthuis	eindstanduit


-- 6.
-- Voeg een kolom Seizoen toe aan Wedstrijd. Dit is iets wat nog zal terugkomen in volgende oefeningen
--wedstrijdID	speeldatum	stamnummerThuis	stamnummerUit	Seizoen


-- 7.
-- Breid de vorige oefening uit zodat nu de namen van de ploegen er staan in plaats van de stamnummers
--wedstrijdID	speeldatum	ploegnaam	ploegnaam	Seizoen


-- 8.
-- Geef een overzicht van het aantal seizoenen dat elke ploeg deelnam aan de competitie
--ploegnaam	Aantal seizoenen


-- 9.
-- Breid de vorige query uit: geef een overzicht van de ploegen die 40 keer of meer deelnamen aan de competitie
--ploegnaam	Aantal seizoenen


-- 9.
-- Geef per ploeg het maximum aantal wedstrijden dat ze ooit wonnen gedurende een seizoen
--ploegnaam	Aantal gewonnen matchen


-- 10.
-- Geef de ploegen die nooit meer dan 10 keer wonnen gedurende een seizoen
--ploegnaam	Aantal gewonnen matchen

