//Always vote for each other
MATCH (c:Country) -[:PARTICIPATED_AS]-> (p:Participant) -[:PARTICIPATED_IN]-> (f:Finale),
(oc:Country) -[:PARTICIPATED_AS]-> (op:Participant) -[:PARTICIPATED_IN]-> (f)
OPTIONAL MATCH (op) -[os:COMPETED_WITH]-> ()
OPTIONAL MATCH (p) -[s:COMPETED_WITH]-> ()
WHERE c.name <> oc.name  
WITH COLLECT(DISTINCT CASE 
            WHEN (s IS NULL)=false AND (os IS NULL)=false
                AND (EXISTS( (p) -[:VOTED_FOR]-> (op) )=false OR EXISTS( (op) -[:VOTED_FOR]-> (p) )=false )
                THEN [c.name, oc.name]
            WHEN s IS NULL AND (os IS NULL)=false
                AND EXISTS( (p) -[:VOTED_FOR]-> (op) )=false
                THEN [c.name, oc.name]
            WHEN (s IS NULL)=false AND os IS NULL
                AND EXISTS( (op) -[:VOTED_FOR]-> (p) )=false
                THEN [c.name, oc.name]
            END) AS C
WITH C
//DISTINCT
MATCH (c:Country) -[:PARTICIPATED_AS]-> (p:Participant) -[:PARTICIPATED_IN]-> (f:Finale),
(oc:Country) -[:PARTICIPATED_AS]-> (op:Participant) -[:PARTICIPATED_IN]-> (f)
WHERE c.name <> oc.name AND NOT [c.name, oc.name] IN C AND NOT [oc.name, c.name] IN C
RETURN DISTINCT c.name, oc.name
