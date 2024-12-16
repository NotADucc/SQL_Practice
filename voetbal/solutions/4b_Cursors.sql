
-- Schrijf een SP die de details van een opgegeven wedstrijd uitschrijft.
-- Schrijf eerst de details van de wedstrijd (datum / tijdstip / thuisploeg / uitploeg / Eindstand) uit 
-- Maak vervolgens gebruik van een cursor om voor de wedstrijd het doelpuntenverloop uit te schrijven
-- Maak gebruik van FORMAT om de datum op een nette manier uit te schrijven
-- https://www.mssqltips.com/sqlservertip/2655/format-sql-server-dates-with-format-function/
-- Maak gebruik van CAST om de getallen uit te schrijven
-- Schrijf testcode

-- Voorbeeld voor wedstrijdID = 18614
--Sunday, March, 2024 19:15   
--KV Kortrijk vs RWDM
--Eindstand = 3 - 2
--1:0     9'
--        24'    1:1
--2:1     63'
--        65'    2:2
--3:2     74'

CREATE OR ALTER PROCEDURE details_wedstrijd @wedstrijdID INT
AS

BEGIN 
	IF NOT EXISTS (SELECT * FROM Wedstrijd WHERE WedstrijdID = @wedstrijdID)
	BEGIN
		RAISERROR('Wedstrijd id bestaat niet', 18, 1)
		RETURN
	END

	DECLARE @speelDatum DATE, @ploegThuis VARCHAR(255), @ploegUit VARCHAR(255), @tijdstip CHAR(8), @eindScoreThuis INT, @eindScoreUit INT;
	DECLARE @scoreMinuten INT, @standThuis INT, @standUit INT, @wieScoorde CHAR(5);

	--declare cursor
	DECLARE wedstrijd_cursor CURSOR 
	FOR
	SELECT w.Speeldatum, p1.ploegnaam, p2.ploegnaam, w.SpeelTijdstip, w.EindstandThuis, w.EindstandUit
	FROM Wedstrijd w
	JOIN Ploeg p1 ON w.StamnummerThuis = p1.stamnummer
	JOIN Ploeg p2 ON w.StamnummerUit = p2.stamnummer
	WHERE w.WedstrijdId = 18614

	-- open cursor
	OPEN wedstrijd_cursor

	-- fetch data
	FETCH NEXT FROM wedstrijd_cursor INTO @speelDatum, @ploegThuis, @ploegUit, @tijdstip, @eindScoreThuis, @eindScoreUit

	WHILE @@FETCH_STATUS = 0 
	BEGIN 
		PRINT CONCAT(FORMAT (@speelDatum, 'dddd, MMMM, yyyy'), ' ', @tijdstip)
		PRINT @ploegThuis + ' vs ' + @ploegUit
		PRINT CONCAT('Eindstand = ', @eindScoreThuis, ' - ', @eindScoreUit)
		--  begin inner cursor
		DECLARE punten_cursor CURSOR FOR
		SELECT ScoreMinuten, DoelpuntenThuis, DoelpuntenUit, WieScoorde FROM Doelpunt WHERE WedstrijdID = @wedstrijdID

		-- open cursor
		OPEN punten_cursor

		-- fetch data
		FETCH NEXT FROM punten_cursor INTO @scoreMinuten, @standThuis, @standUit, @wieScoorde
		--1:0     9'
		--        24'    1:1
		--2:1     63'
		--        65'    2:2
		--3:2     74'
		WHILE @@FETCH_STATUS = 0 
		BEGIN
			PRINT CASE WHEN @wieScoorde = 'T' 
				THEN CONCAT(@standThuis, ':', @standUit) + '	' + CONCAT(@scoreMinuten, '''')
				ELSE '	' + CONCAT(@scoreMinuten, '''') + '		' + CONCAT(@standThuis, ':', @standUit) END
			FETCH NEXT FROM punten_cursor INTO @scoreMinuten, @standThuis, @standUit, @wieScoorde
		END

		CLOSE punten_cursor

		-- deallocate cursor
		DEALLOCATE punten_cursor

		-- end inner cursor
  		FETCH NEXT FROM wedstrijd_cursor INTO @speelDatum, @ploegThuis, @ploegUit, @tijdstip, @eindScoreThuis, @eindScoreUit
	END 

	-- close cursor
	CLOSE wedstrijd_cursor

	-- deallocate cursor
	DEALLOCATE wedstrijd_cursor
END
GO;
-- Testcode

DECLARE @wedstrijdID INT = 18614
EXEC details_wedstrijd @wedstrijdID
GO

-- We vragen ons af of er in het begin van de wedstrijd meer doelpunten worden gescoord dan in het einde van de wedstrijd

-- Creëer eerst een CTE waarbij per doelpunt het kwartier wordt gegeven: 00-15 / 16-30 / 31-45 / 46-60 / 61-75 / 76-90
-- Laat de doelpunten in de toegevoegde tijd buiten beschouwing.
-- Bereken het totaal aantal doelpunten dat er per kwartier werden gescoord 
-- Maak gebruik van een cursor voor een visuele weergave. Gebruik de functie REPLICATE('x', @aantal_doelpunten / 100).

--00-15 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--16-30 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--31-45 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--46-60 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--61-75 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
--76-90 xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

WITH time_slots AS (
	SELECT 0 start_time, end_time = 15
	UNION ALL
	SELECT end_time + 1, end_time + 15
	FROM time_slots
	WHERE end_time < 90
),
time_slot_doelpunten AS (
	SELECT COUNT(*) aantal_punten
	FROM Doelpunt d
	JOIN time_slots ts ON d.SpeelTijdstip BETWEEN ts.start_time AND ts.end_time
	GROUP BY ts.start_time, ts.end_time
)
SELECT *
FROM time_slot_doelpunten

-- Maak gebruik van een geneste cursor om per seizoen de top 6 op de laatste speeldag te tonen
--1960/1961 
--   1: Standard Luik
--   2: RFC Luik
--   3: RSC Anderlecht
--   4: Beerschot
--   5: Daring Club Brussel
--   6: Waterschei SV Thor
 
--1961/1962 
--   1: RSC Anderlecht
--   2: Standard Luik
--   3: Royal Antwerp FC
--   4: RFC Luik
--   5: Club Brugge
--   6: Daring Club Brussel






-- Schrijf een stored procedure die voor een opgegeven ploeg per seizoen de positie op de laatste dag van de competitie uitschrijft
-- Als de opgegeven ploeg dat seizoen niet heeft deelgenomen, verschijnt '/'
-- Als de opgegeven ploeg niet bestaat wordt een foutmelding uitgeschreven en stopt de uitvoer van het programma
-- Het moet wel zo zijn, dat bijvoorbeeld Aalst ook OK is als ploegnaam, en niet enkel Eendracht Aalst, of Gent ipv KAA Gent
-- Het aantal keer dat de ploeg deelnam aan de competitie wordt teruggegeven aan het hoofdprogramma
-- Schrijf testcode voor Aalst
-- Hoewel deze oefening goed op de voorgaande gelijkt, heb je geen geneste cursor nodig om dit op te lossen

--1960/1961 : 12
--1961/1962 : 16
--1962/1963 : /
--1963/1964 : /
--1964/1965 : /
--1965/1966 : /
--1966/1967 : /
--1967/1968 : /
--1968/1969 : /

CREATE OR ALTER PROCEDURE eindstand @ploegnaam VARCHAR(255), @aantal_competities INT OUT
AS
BEGIN

END

-- Testcode

