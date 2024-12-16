-- Schrijf een SP die de ploegnaam van een opgegeven stamnummer verandert naar een opgegeven nieuwe naam
-- Als het stamnummer niet bestaat, dan wordt een exception opgegooid en wordt de rest van de procedure niet meer uitgevoerd
-- Als de opgegeven nieuwe naam, gelijk is aan de oude naam, wordt een melding geprint en wordt de rest van de procedure niet meer uitgevoerd
-- Schrijf testcode. Gebruikt transacties zodat de databank ongewijzigd blijft
-- Je kan de error messages in Messages zien
-- (1) Update de naam van ploeg 18 naar OH Leuven (was Oud-Heverlee Leuven)
-- (2) Update de naam van ploeg 18 naar Oud-Heverlee Leuven (was Oud-Heverlee Leuven)
-- (3) Update de naam van ploeg 118 naar OH Leuven (bestaat niet)

CREATE OR ALTER PROCEDURE verander_ploegnaam @stamnummer INT, @nieuwe_ploegnaam VARCHAR(255)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM Ploeg WHERE stamnummer = @stamnummer)
	BEGIN
		RAISERROR('Stamnummer bestaat niet', 18, 1);
		RETURN;
	END

	DECLARE @oude_naam VARCHAR(255) = (SELECT ploegnaam FROM Ploeg WHERE stamnummer = @stamnummer)

	IF @oude_naam = @nieuwe_ploegnaam 
	BEGIN
		RAISERROR('ploegnaam is niet veranderd' ,18, 1)
		RETURN;
	END

	UPDATE Ploeg
	SET ploegnaam = @nieuwe_ploegnaam
	WHERE stamnummer = @stamnummer
END

-- Testcode 1
BEGIN TRANSACTION 
-- Oorspronkelijke waarde = Oud-Heverlee Leuven
EXEC verander_ploegnaam 18, 'OH Leuven'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Ploeg WHERE stamnummer = 18

ROLLBACK;

-- Testcode 2
BEGIN TRANSACTION 
-- Oorspronkelijke waarde = Oud-Heverlee Leuven
EXEC verander_ploegnaam 18, 'Oud-Heverlee Leuven'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Ploeg WHERE stamnummer = 18

ROLLBACK;

-- Testcode 3
BEGIN TRANSACTION 
-- Ploeg bestaat niet
EXEC verander_ploegnaam 118, 'Oud-Heverlee Leuven'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Ploeg WHERE stamnummer = 18

ROLLBACK;

GO;

-- Schrijf een SP die het wedstrijdType van een opgegeven WedstrijdID verandert naar een ander wedstrijdType
-- Als de WedstrijdID niet bestaat, dan wordt een exception opgegooid en wordt de rest van de procedure niet meer uitgevoerd
-- Als het opgeven wedstrijdType niet één van de 3 al aanwezige wedstrijdTypes is, dan wordt een exception opgegooid en wordt de rest van de procedure niet meer uitgevoerd
-- Schrijf testcode. Gebruikt transacties zodat de databank ongewijzigd blijft
-- Je kan de error messages in Messages zien
-- (1) Update het wedstrijdType van wedstrijd 14364 naar Playoff_2 (was Playoff_1)
-- (2) Update het wedstrijdType van wedstrijd 14364 naar Playoffff_1 (was Playoff_1)
-- (3) Update het wedstrijdType van wedstrijd 1004364 naar Playoff_2 (wedstrijd bestaat niet)

CREATE OR ALTER PROCEDURE verander_wedstrijdType @wedstrijdID INT, @nieuw_wedstrijdType VARCHAR(50)
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM Wedstrijd WHERE WedstrijdID = @wedstrijdID)
	BEGIN
		RAISERROR('Wedstrijd id bestaat niet',18,1);
		RETURN;
	END

	IF @nieuw_wedstrijdType NOT IN ('regulier', 'playoff_1', 'playoff_2')
	BEGIN
		RAISERROR('Wedstrijd type bestaat niet',18,1);
		RETURN;
	END

	UPDATE Wedstrijd
	SET WedstrijdType = @nieuw_wedstrijdType
	WHERE WedstrijdID = @wedstrijdID
END



-- Testcode 1
BEGIN TRANSACTION 
-- Oorspronkelijke waarde = Playoff_1
EXEC verander_wedstrijdType 14364, 'Playoff_2'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Wedstrijd WHERE wedstrijdID = 14364

ROLLBACK;

-- Testcode 2
BEGIN TRANSACTION 
-- Oorspronkelijke waarde = Playoff_1
EXEC verander_wedstrijdType 14364, 'Playofff_1'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Wedstrijd WHERE wedstrijdID = 14364

ROLLBACK;

-- Testcode 3
BEGIN TRANSACTION 
-- Wedstrijd bestaat niet
EXEC verander_wedstrijdType 1004364, 'Playoff_2'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Wedstrijd WHERE wedstrijdID = 14364

ROLLBACK;

GO;

-- Schrijf een Function bereken_seizoen die op basis van de datum het seizoen geeft
-- Test de functie

CREATE OR ALTER FUNCTION bereken_seizoen(@speeldatum date) RETURNS CHAR(10)
AS
BEGIN
	DECLARE @yr INT = YEAR(@speeldatum);
	RETURN CASE WHEN MONTH(@speeldatum) < 7 THEN CONCAT(@yr - 1, '/', @yr) ELSE CONCAT(@yr, '/', @yr + 1) END;
END

GO;
-- Testcode
PRINT(dbo.bereken_seizoen('1989/04/27')) -- 1988/1989
PRINT(dbo.bereken_seizoen('2005/12/06')) -- 2005/2006

GO;

-- Schrijf een SP die de datum van een opgegeven WedstrijdID verandert naar een andere datum
-- Als de wedstrijdID niet bestaat => exception + de procedure wordt niet meer verder uitgevoerd
-- Als de nieuwe datum in een ander seizoen valt => exception + de procedure wordt niet meer verder uitgevoerd
-- Maak hiervoor gebruik van de functie bereken_seizoen
-- Als de nieuwe datum op een maandag of dinsdag valt => exception + de procedure wordt niet meer verder uitgevoerd
-- Als één van de beide ploegen al een wedstrijd heeft op die dag => exception + de procedure wordt niet meer verder uitgevoerd
-- Schrijf testcode. Gebruikt transacties zodat de databank ongewijzigd blijft
-- Je kan de error messages in Messages zien
-- (1) Update de datum van wedstrijd 180623 naar 2024/03/15 (wedstrijd bestaat niet)
-- (2) Update de datum van wedstrijd 18623 naar 2023/03/15 (valt in een ander seizoen)
-- (3) Update de datum van wedstrijd 18623 naar 2024/03/11 (maandag)
-- (4) Update de datum van wedstrijd 18623 naar 2024/03/11 (dinsdag)
-- (5) Update de datum van wedstrijd 18623 naar 2024/03/16 (thuisploeg speelt dan al een wedstrijd)
-- (6) Update de datum van wedstrijd 18623 naar 2024/03/10 (uitploeg speelt dan al een wedstrijd)
-- (7) Update de datum van wedstrijd 18623 naar 2024/03/15 (ok)

CREATE OR ALTER PROCEDURE verander_datum @wedstrijdID INT, @nieuwe_datum date
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM Wedstrijd WHERE WedstrijdID = @wedstrijdID)
	BEGIN
		RAISERROR('wedstrijd id doesn''t exist',18,1)
		RETURN;
	END

	DECLARE @huidige_speeldatum DATE = (SELECT Speeldatum FROM Wedstrijd WHERE WedstrijdID = @wedstrijdID);
	DECLARE @huidige_seizoen CHAR(10) = (CASE WHEN MONTH(@huidige_speeldatum) < 7 THEN CONCAT(YEAR(@huidige_speeldatum) - 1, '/', YEAR(@huidige_speeldatum)) ELSE CONCAT(YEAR(@huidige_speeldatum), '/', YEAR(@huidige_speeldatum) + 1) END);
	DECLARE @nieuwe_seizoen CHAR(10) = (CASE WHEN MONTH(@nieuwe_datum) < 7 THEN CONCAT(YEAR(@nieuwe_datum) - 1, '/', YEAR(@nieuwe_datum)) ELSE CONCAT(YEAR(@nieuwe_datum), '/', YEAR(@nieuwe_datum) + 1) END);

	IF @huidige_seizoen NOT LIKE @nieuwe_seizoen 
	BEGIN
		RAISERROR('nieuwe speeldatum is niet in het huidige seizoen',18,1);
		RETURN;
	END

	IF DATEPART(dw, @nieuwe_datum) IN (2, 3)
	BEGIN
		RAISERROR('nieuwe speeldatum mag niet op een maandag of dinsdag vallen',18,1)
		RETURN;
	END

	DECLARE @thuis INT = (SELECT StamnummerThuis FROM Wedstrijd WHERE WedstrijdID = @wedstrijdID);
	DECLARE @uit INT = (SELECT StamnummerUit FROM Wedstrijd WHERE WedstrijdID = @wedstrijdID);

	IF EXISTS (SELECT * FROM Wedstrijd WHERE Speeldatum = @nieuwe_datum AND (StamnummerThuis IN (@thuis, @uit) OR StamnummerUit IN (@thuis, @uit)))
	BEGIN
		RAISERROR('nieuwe speeldag overlapt met een andere speeldag van een ploeg',18,1);
		RETURN;
	END

	UPDATE Wedstrijd
	SET Speeldatum = @nieuwe_datum
	WHERE WedstrijdID = @wedstrijdID
END

GO;



-- Testcode 1
BEGIN TRANSACTION 
-- Er is geen wedstrijd 180623
EXEC verander_datum 180610, '2024/03/15'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Wedstrijd WHERE wedstrijdID = 18610

ROLLBACK;

-- Testcode 2
BEGIN TRANSACTION 
-- De nieuwe datum valt in een ander seizoen
EXEC verander_datum 18610, '2023/03/15'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Wedstrijd WHERE wedstrijdID = 18610

ROLLBACK;

-- Testcode 3
BEGIN TRANSACTION 
-- De nieuwe datum valt op een maandag
EXEC verander_datum 18610, '2024/03/11'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Wedstrijd WHERE wedstrijdID = 18610

ROLLBACK;

-- Testcode 4
BEGIN TRANSACTION 
-- De nieuwe datum valt op een dinsdag
EXEC verander_datum 18610, '2024/03/12'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Wedstrijd WHERE wedstrijdID = 18610

ROLLBACK;

-- Testcode 5
BEGIN TRANSACTION 
-- Op de nieuwe datum speelt de thuisploeg al een wedstrijd
EXEC verander_datum 18610, '2024/03/16'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Wedstrijd WHERE wedstrijdID = 18610

ROLLBACK;


-- Testcode 6
BEGIN TRANSACTION 
-- Op de nieuwe datum speelt de uitploeg al een wedstrijd
EXEC verander_datum 18610, '2024/03/10'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Wedstrijd WHERE wedstrijdID = 18610

ROLLBACK;


-- Testcode 7
BEGIN TRANSACTION 
-- Datum verandert van 2024/03/02 naar 2024/03/09
EXEC verander_datum 18610, '2024/03/09'

-- Enkel in deze sessie is de verandering te zien
SELECT * FROM Wedstrijd WHERE wedstrijdID = 18610

ROLLBACK;
