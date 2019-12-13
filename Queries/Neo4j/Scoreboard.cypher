//Scoreboard
MATCH () -[v:VOTED_FOR]-> (a:Participant) -[:PARTICIPATED_IN]-> (:Finale {year:2009, type:'f'})
RETURN a.country as Country, SUM(v.points) as Points
ORDER BY Points DESC