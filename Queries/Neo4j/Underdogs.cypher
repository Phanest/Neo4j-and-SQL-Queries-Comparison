//Find the underdogs
MATCH () -[v:VOTED_FOR]-> (cont:Participant) -[:PARTICIPATED_IN]-> (f:Finale),
(country:Country) -[:PARTICIPATED_AS]-> (cont)
WITH country.name as name, SUM(v.points) as Points, f.year as year, f.type as type, cont.coefficient as coefficient
ORDER BY Points DESC
WITH year, type, COLLECT([name, Points, year, type, coefficient])[..10] as C UNWIND C AS a
WITH a[0] as name, a[1] as Points, a[2] as year, a[3] as type, a[4] as coefficient
WHERE coefficient <= 50
RETURN name, Points, year, type, coefficient
ORDER BY year DESC
