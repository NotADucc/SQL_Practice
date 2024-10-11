-- 1.
-- Welke ploeg bleef ongeslagen tijdens een seizoen? Nooit verloren tijdens een volledig seizoen
-- AantalVerloren op de laatste speeldag gelijk aan 0.
-- Creëer een CTE die het maximum aantal speeldagen per seizoen berekent
-- Maak gebruik van deze CTE om het aantal verloren matchen te kennen op de laatste speeldag


-- 2.
-- In hoeveel procent van de reguliere wedstrijden wordt er maar door 1 ploeg gescoord?
-- CTE die het totaal aantal reguliere wedstrijden berekent
-- CTE die het aantal reguliere wedstrijden telt waarbij Thuis of Uit score gelijk is aan 0
-- Combineer de beide CTE's


-- 3.
-- In 1995 werd overgeschakeld van het 2 punten systeem naar het 3 punten systeem.
-- De bedoeling was om het voetbal aanvallender te maken.
-- Wat is het gemiddeld aantal doelpunten vóór 01/07/1995 en sinds 01/07/1995
-- cte_1 --> extra kolom met totaal aantal doelpunten
-- cte_2 --> gemiddeld aantal doelpunten vóór 01/07/1995
-- ...
--Gemiddeld aantal doelpunten voor 1995	Gemiddeld aantal doelpunten na 1995


-- 4.
-- Hoeveel procent van de doelpunten valt in de eerste helft en hoeveel procent van de doelpunten valt in de tweede helft?
-- Laat de doelpunten in de toegevoegde tijd buiten beschouwing.
-- CTE die aantal doelpunten in de eerste helft berekent
-- CTE die aantal doelpunten in de tweede helft berekent
-- Combineer de beide CTE's
--Eerste helft	Tweede helft


-- 5.
-- Voor eens en voor altijd: bestaat er zoiets als het thuisvoordeel?
-- Hoeveel procent van de matchen wordt gewonnen door de thuisploeg?
-- Creëer een CTE die per wedstrijd weergeeft wie er won (Thuis / Uit / Gelijk)
-- Creëer een CTE die het totaal aantal wedstrijden in de databank telt
-- Combineer de beide om het procentuele aantal matchen gewonnen door de thuisploeg, te berekenen
--WieWint	procentueel deel


-- 6.
-- Stel dat Club Brugge thuis tegen Cercle Brugge speelt.
-- Je vraagt je af in hoeveel procent van de gevallen Club Brugge in het verleden al won bij deze stadsderby.
-- CTE die aantal stadsderby's tussen de beide ploegen telt
-- CTE die aantal stadsderby's telt waarbij Club Brugge won


-- 7.
-- Hoeveel procent van de ploegen die op speeldag 10 in de top 6 staan, staan op de laatste speeldag ook nog in de top 6 van het klassement?
-- Maak een CTE die seizoen + stamnummer bevat van de ploegen die op speeldag 10 in top 6 van klassement staan
-- Maak een CTE die per seizoen de laatste speeldag geeft (30 / 34 / 38)
-- Maak met behulp van de voorgaande CTE een nieuwe CTE die seizoen + stamnummer bevat van de ploegen die op de laatste speeldag in top 6 van klassement staan
-- Combineer de eerste en laatste CTE om het resultaat te kennen


-- 8.
-- Geef per seizoen een lijst met alle wedstrijden met een maximum totaal aantal doelpunten
-- Maak een CTE die op basis van de speeldatum het overeenkomstige seizoen vindt
-- Maak een CTE die het maximum totaal aantal doelpunten per seizoen bepaalt
-- Combineer de beide
--wedstrijdid	seizoen	ploegnaam	ploegnaam	aantal_doelpunten


-- 9.
-- In hoeveel procent van de wedstrijden is de eindstand gelijk