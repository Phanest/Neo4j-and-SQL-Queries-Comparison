//Always votes for winner
MATCH (e:Eurovision)
WITH e
MATCH () -[v:VOTED_FOR]-> (cont:Participant) -[:PARTICIPATED_IN]-> (:Finale {year:e.year, type:'f'}),
(country:Country) -[:PARTICIPATED_AS]-> (cont)
WITH country.name as name, SUM(v.points) as Points, e.year as year
ORDER BY Points DESC
WITH year, COLLECT({name:name, year:year})[..1] as C UNWIND C AS a
//Find all countries who voted for the winner
//todo if someone wins then he can't vote for himself
MATCH (c:Country) -[:PARTICIPATED_AS]-> (p:Participant) -[:PARTICIPATED_IN]-> (f:Finale {year:a.year, type:'f'})
//WITH c, p, a
OPTIONAL MATCH (p) -[v:VOTED_FOR]-> (:Participant {country:a.name}) -[:PARTICIPATED_IN]-> (f)
WHERE c.name <> a.name
WITH COLLECT(DISTINCT CASE WHEN v IS NULL THEN c END) as a
//Check which countries are not in the list
MATCH (c:Country)
WHERE NOT c IN a
RETURN c