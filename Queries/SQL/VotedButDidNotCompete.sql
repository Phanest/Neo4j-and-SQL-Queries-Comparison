
SELECT DISTINCT from_country as country, euroid FROM Vote
EXCEPT
SELECT country, euroid FROM Competed