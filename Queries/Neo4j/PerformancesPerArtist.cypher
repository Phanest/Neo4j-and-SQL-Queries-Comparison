//Count performances (songs) per artist
MATCH (a:Artist) -[:MADE]-> (b:Song)
RETURN a.name as Name, COUNT(DISTINCT b.name) as Count
ORDER BY Count DESC