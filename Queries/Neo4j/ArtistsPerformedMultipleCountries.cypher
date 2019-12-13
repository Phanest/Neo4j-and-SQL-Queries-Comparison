//Has an artist represented more than one country
MATCH (a:Artist) -[:MADE]-> (:Song) <-[:COMPETED_WITH]- () <-[:PARTICIPATED_AS]- (b:Country)
WITH a.name as Name, COLLECT(DISTINCT b.name) as Countries, COUNT(DISTINCT b.name) as Count
WHERE Count > 1
RETURN Name, Countries, Count