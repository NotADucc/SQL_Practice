-- 1.
-- Welke ploeg bleef ongeslagen tijdens een seizoen? Nooit verloren tijdens een volledig seizoen
-- AantalVerloren op de laatste speeldag gelijk aan 0.
-- Creëer een CTE die het maximum aantal speeldagen per seizoen berekent
-- Maak gebruik van deze CTE om het aantal verloren matchen te kennen op de laatste speeldag
-- Het resultaat is leeg
WITH aantalDagenSeizoen AS (
	SELECT Seizoen, MAX(Speeldag) maxDagen
	FROM Klassement
	GROUP BY Seizoen
)
SELECT *
FROM Klassement k
JOIN aantalDagenSeizoen ad ON k.Seizoen = ad.Seizoen AND k.Speeldag = ad.maxDagen
WHERE AantalVerloren = 0
GO


-- 2.
-- In hoeveel procent van de reguliere wedstrijden wordt er maar door 1 ploeg gescoord?
-- CTE die het totaal aantal reguliere wedstrijden berekent
-- CTE die het aantal reguliere wedstrijden telt waarbij Thuis of Uit score gelijk is aan 0
-- Combineer de beide CTE's
-- 40.36%
WITH aantalReguliereWedstrijden AS (
	SELECT COUNT(*) AantalReguliereWedstrijden
	FROM Wedstrijd
	WHERE WedstrijdType = 'regulier'
),
dominanteRegulierWedstrijden AS (
	SELECT COUNT(*) AantalDominanteReguliereWedstrijden
	FROM Wedstrijd
	WHERE WedstrijdType = 'regulier' AND ((EindstandThuis != 0 AND EindstandUit = 0) OR (EindstandThuis = 0 AND EindstandUit != 0))
)
SELECT FORMAT((SELECT AantalDominanteReguliereWedstrijden FROM dominanteRegulierWedstrijden) * 1.0 / AantalReguliereWedstrijden, 'P')
FROM aantalReguliereWedstrijden
GO
-- no clue how you get 40.36%, i get 39.874902267396


-- 3.
-- In 1995 werd overgeschakeld van het 2 punten systeem naar het 3 punten systeem.
-- De bedoeling was om het voetbal aanvallender te maken.
-- Wat is het gemiddeld aantal doelpunten vóór 01/07/1995 en sinds 01/07/1995
-- cte_1 --> extra kolom met totaal aantal doelpunten
-- cte_2 --> gemiddeld aantal doelpunten vóór 01/07/1995
-- ...
--Gemiddeld aantal doelpunten voor 1995	Gemiddeld aantal doelpunten na 1995
--2.740501								2.902450
WITH cte_1 AS (
	SELECT COUNT(*) totaal, SUM(EindstandThuis + EindstandUit) doelPunten
	FROM Wedstrijd
	WHERE Speeldatum < CONVERT(date, '01/07/1995', 103)
),
cte_2 AS (
	SELECT COUNT(*) totaal, SUM(EindstandThuis + EindstandUit) doelPunten
	FROM Wedstrijd
	WHERE Speeldatum > CONVERT(date, '01/07/1995', 103)
)
SELECT cte_1.doelPunten * 1.0 / cte_1.totaal 'Gemiddeld aantal doelpunten voor 1995',
	cte_2.doelPunten * 1.0 / cte_2.totaal 'Gemiddeld aantal doelpunten na 1995'
FROM cte_1
CROSS JOIN cte_2
GO


-- 4.
-- Hoeveel procent van de doelpunten valt in de eerste helft en hoeveel procent van de doelpunten valt in de tweede helft?
-- Laat de doelpunten in de toegevoegde tijd buiten beschouwing.
-- CTE die aantal doelpunten in de eerste helft berekent
-- CTE die aantal doelpunten in de tweede helft berekent
-- Combineer de beide CTE's
--Eerste helft	Tweede helft
--0.431732863697	0.568267136302
WITH eersteHelft AS (
	SELECT COUNT(*) doelPunten
	FROM Doelpunt
	WHERE ScoreMinuten <= 45
),
tweedeHelft AS (
	SELECT COUNT(*) doelPunten
	FROM Doelpunt
	WHERE ScoreMinuten > 45 AND ScoreMinuten <= 90
)
SELECT 
	(SELECT * FROM eersteHelft) * 1.0 / SUM(t.doelPunten) 'Eerste helft',
	(SELECT * FROM tweedeHelft) * 1.0 / SUM(t.doelPunten) 'Tweede helft'
FROM 
(
	SELECT doelPunten FROM eersteHelft
	UNION 
	SELECT doelPunten FROM tweedeHelft
) t
GO


-- 5.
-- Voor eens en voor altijd: bestaat er zoiets als het thuisvoordeel?
-- Hoeveel procent van de matchen wordt gewonnen door de thuisploeg?
-- Creëer een CTE die per wedstrijd weergeeft wie er won (Thuis / Uit / Gelijk)
-- Creëer een CTE die het totaal aantal wedstrijden in de databank telt
-- Combineer de beide om het procentuele aantal matchen gewonnen door de thuisploeg, te berekenen
--WieWint	procentueel deel
--Gelijk	0.258024691358
--Thuis		0.481910896403
--Uit		0.260064412238
WITH winnaarWedstrijden AS (
	SELECT 
		* , 
		CASE WHEN EindstandThuis > EindstandUit THEN 'Thuis'
		WHEN EindstandThuis < EindstandUit THEN 'Uit'
		ELSE 'Gelijk' END 'winnaar'
	FROM Wedstrijd
),
totaalWedstrijden AS (
	SELECT COUNT(*) totaal
	FROM Wedstrijd
)
SELECT WieWint, totaalPerGroep * 1.0 / totaal 'procentueel deel'
FROM 
(
	SELECT winnaar 'WieWint', COUNT(*) totaalPerGroep
	FROM winnaarWedstrijden
	GROUP BY winnaar
) t
CROSS JOIN totaalWedstrijden
ORDER BY WieWint
GO


-- 6.
-- Stel dat Club Brugge thuis tegen Cercle Brugge speelt.
-- Je vraagt je af in hoeveel procent van de gevallen Club Brugge in het verleden al won bij deze stadsderby.
-- CTE die aantal stadsderby's tussen de beide ploegen telt
-- CTE die aantal stadsderby's telt waarbij Club Brugge won
-- 66.6% 
DECLARE @ploeg1 VARCHAR(55) = 'Club Brugge';
DECLARE @ploeg2 VARCHAR(55) = 'Cercle Brugge';
WITH beideTotaal AS (
	SELECT COUNT(*) totaal
	FROM Wedstrijd w
	JOIN Ploeg p_t ON w.StamnummerThuis = p_t.stamnummer
	JOIN Ploeg p_u ON w.StamnummerUit = p_u.stamnummer
	WHERE p_t.ploegnaam IN (@ploeg1) AND p_u.ploegnaam IN(@ploeg2)
),
ploeg1Totaal AS (
	SELECT COUNT(*) totaal
	FROM Wedstrijd w
	JOIN Ploeg p_t ON w.StamnummerThuis = p_t.stamnummer
	JOIN Ploeg p_u ON w.StamnummerUit = p_u.stamnummer
	WHERE p_t.ploegnaam IN (@ploeg1) AND p_u.ploegnaam IN(@ploeg2) AND w.EindstandThuis > w.EindstandUit
)
SELECT CONCAT((SELECT totaal FROM ploeg1Totaal) * 100.0 / totaal, '%')
FROM beideTotaal
GO

-- of

DECLARE @ploeg1 VARCHAR(55) = 'Club Brugge';
DECLARE @ploeg2 VARCHAR(55) = 'Cercle Brugge';
WITH beideTotaal AS (
	SELECT w.EindstandThuis, w.EindstandUit
	FROM Wedstrijd w
	JOIN Ploeg p_t ON w.StamnummerThuis = p_t.stamnummer
	JOIN Ploeg p_u ON w.StamnummerUit = p_u.stamnummer
	WHERE p_t.ploegnaam IN (@ploeg1) AND p_u.ploegnaam IN(@ploeg2)
),
ploeg1Totaal AS (
	SELECT COUNT(*) totaal
	FROM beideTotaal
	WHERE EindstandThuis > EindstandUit
)
SELECT FORMAT((SELECT totaal FROM ploeg1Totaal) * 1.0 / COUNT(*), 'P')
FROM beideTotaal
GO


-- 7.
-- Hoeveel procent van de ploegen die op speeldag 10 in de top 6 staan, staan op de laatste speeldag ook nog in de top 6 van het klassement?
-- Maak een CTE die seizoen + stamnummer bevat van de ploegen die op speeldag 10 in top 6 van klassement staan
-- Maak een CTE die per seizoen de laatste speeldag geeft (30 / 34 / 38)
-- Maak met behulp van de voorgaande CTE een nieuwe CTE die seizoen + stamnummer bevat van de ploegen die op de laatste speeldag in top 6 van klassement staan
-- Combineer de eerste en laatste CTE om het resultaat te kennen
-- 73.17%
WITH max_seizoen AS (
	SELECT Seizoen, MAX(Speeldag) max_speeldag
	FROM Klassement
	GROUP BY Seizoen
),
tiende_speeldag AS (
	SELECT Stamnummer, Seizoen
	FROM Klassement
	WHERE Speeldag = 10 AND Positie <= 6
),
max_seizoen_posities AS (
	SELECT k.Seizoen, k.Stamnummer
	FROM Klassement k
	JOIN max_seizoen ms ON k.Seizoen = ms.Seizoen AND k.Speeldag = ms.max_speeldag
	WHERE k.Positie <= 6
)
SELECT FORMAT(COUNT(*) * 1.0 / (SELECT COUNT(*) FROM tiende_speeldag), 'P')
FROM max_seizoen_posities msp
JOIN tiende_speeldag ts ON ts.Stamnummer = msp.Stamnummer AND ts.Seizoen = msp.Seizoen


-- 8.
-- Geef per seizoen een lijst met alle wedstrijden met een maximum totaal aantal doelpunten
-- Maak een CTE die op basis van de speeldatum het overeenkomstige seizoen vindt
-- Maak een CTE die het maximum totaal aantal doelpunten per seizoen bepaalt
-- Combineer de beide
--wedstrijdid	seizoen	ploegnaam	ploegnaam	aantal_doelpunten
--77	1960/1961	Beerschot	Eendracht Aalst	11
--260	1961/1962	Olympic Charleroi	Cercle Brugge	9
--487	1962/1963	Royal Antwerp FC	KAA Gent	8
--500	1962/1963	Beringen FC	Daring Club Brussel	8
--544	1962/1963	Club Brugge	KAA Gent	8
--651	1962/1963	RFC Luik	KAA Gent	8
--755	1963/1964	KFC Diest	Beerschot	11
--971	1964/1965	RFC Luik	Beringen FC	11
--1049	1964/1965	RFC Tilleur	Royal Antwerp FC	11

WITH cte1 AS (
	SELECT *,
	CASE 
		WHEN MONTH(Speeldatum) IN (7, 8, 9, 10, 11, 12) THEN CONCAT(YEAR(Speeldatum),'/',YEAR(Speeldatum) + 1)
		ELSE CONCAT(YEAR(Speeldatum) - 1,'/',YEAR(Speeldatum))
		END 'Seizoen'
	FROM Wedstrijd
),
cte2 AS (
	SELECT Seizoen, MAX(EindstandThuis + EindstandUit) 'max_doelpunten'
	FROM cte1
	GROUP BY Seizoen
)
SELECT cte1.WedstrijdID, cte1.Seizoen, p1.ploegnaam, p2.ploegnaam, cte2.max_doelpunten 'aantal_doelpunten'
FROM cte1
JOIN cte2 ON cte1.Seizoen = cte2.Seizoen AND EindstandThuis + EindstandUit = max_doelpunten
JOIN Ploeg p1 ON cte1.StamnummerThuis = p1.stamnummer
JOIN Ploeg p2 ON cte1.StamnummerUit = p2.stamnummer
GO


-- 9.
-- In hoeveel procent van de wedstrijden is de eindstand gelijk
-- 25.80%
WITH cte1 AS (
	SELECT COUNT(*) totaal
	FROM Wedstrijd
	WHERE EindstandThuis = EindstandUit
)
SELECT FORMAT((SELECT totaal FROM cte1) * 1.0 / COUNT(*), 'P')
FROM Wedstrijd