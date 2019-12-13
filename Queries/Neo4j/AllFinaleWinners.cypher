//All finale winners
MATCH (e:Eurovision)
WITH e
MATCH () -[v:VOTED_FOR]-> (cont:Participant) -[:PARTICIPATED_IN]-> (:Finale {year:e.year, type:'f'}),
(country:Country) -[:PARTICIPATED_AS]-> (cont)
WITH country.name as name, SUM(v.points) as Points, e.year as year
ORDER BY Points DESC
WITH year, COLLECT([name, Points, year])[..1] as C UNWIND C AS a
RETURN a[0] as name, a[1] as Points, a[2] as year
ORDER BY year DESC