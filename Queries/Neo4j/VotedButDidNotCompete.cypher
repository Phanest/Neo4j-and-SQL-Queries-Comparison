//Voted but did not compete
MATCH (a:Country) -[:PARTICIPATED_AS]-> (b:Participant) -[:PARTICIPATED_IN]-> (c:Finale) <-[:HAD_FINALE]- (d:Eurovision)
OPTIONAL MATCH (b) -[:COMPETED_WITH]-> (s:Song)
WITH d.year as year, a.name as name, COLLECT(s.name) as C
WHERE size(C) = 0
RETURN name, year