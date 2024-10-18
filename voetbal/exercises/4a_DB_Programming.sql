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


-- Schrijf een Function bereken_seizoen die op basis van de datum het seizoen geeft
-- Test de functie

CREATE OR ALTER FUNCTION bereken_seizoen(@speeldatum date) RETURNS CHAR(10)
AS

BEGIN

END


-- Testcode
PRINT(dbo.bereken_seizoen('1989/04/27')) -- 1988/1989
PRINT(dbo.bereken_seizoen('2005/12/06')) -- 2005/2006


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



END




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
