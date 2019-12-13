
LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
MERGE (:Song {name:nodes.Song, id:nodes.`songid`})

LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
FOREACH (n IN (CASE WHEN nodes.`English translation` IN ['None'] OR nodes.`English translation` IS NULL THEN [] ELSE [1] END) |
    MERGE (:Song:Translation {name:nodes.`English translation`, id:nodes.songid}) )
    
LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
FOREACH (n IN (CASE WHEN nodes.`Song language4` IN ['None'] OR nodes.`Song language4` IS NULL THEN [] ELSE [1] END) |
    MERGE (:Language {name:nodes.`Song language4`}) )

LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
FOREACH (n IN (CASE WHEN nodes.`Artist gender` IN ['None'] OR nodes.`Artist gender` IS NULL THEN [] ELSE [1] END) |
    MERGE (:Gender {gender:nodes.`Artist gender`}) )

LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
MERGE (:Participant {country:nodes.`Country`, year:toInteger(nodes.year), type:nodes.type})

LOAD CSV WITH HEADERS FROM "file:///Participants.csv" AS nodes
MERGE (:Participant {country:nodes.`country`, year:toInteger(nodes.year), type:nodes.type})

LOAD CSV WITH HEADERS FROM "file:///Participants.csv" AS nodes
MATCH (a:Participant {country:nodes.`country`, type:nodes.type, year:toInteger(nodes.year)}),
(b:Country {name:nodes.`country`})  
MERGE (b)-[:PARTICIPATED_AS]->(a)

LOAD CSV WITH HEADERS FROM "file:///Participants.csv" AS nodes
MATCH (a:Participant {country:nodes.`country`, year:toInteger(nodes.year), type:nodes.type}),
(b:Finale {type:nodes.`type`, year:toInteger(nodes.year)})
MERGE (a)-[:PARTICIPATED_IN]->(b)

MATCH (a:Eurovision),
(b:Eurovision {year:a.year+1})
MERGE (a) -[:SUCCEEDED_BY]-> (b)


MATCH (a:Eurovision),
(b:Eurovision {year:a.year+1})
MERGE
(b) -[:PRECEDED_BY]-> (a)


LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
MATCH (a:Country {name:nodes.`Country`}),
(b:Region {region:nodes.`Region`})
MERGE (a) -[:IN_REGION]-> (b)

LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
MATCH (a:Participant {country:nodes.`Country`, year:toInteger(nodes.year), type:nodes.type}),
(b:Song {name:nodes.Song, id:nodes.`songid`})
MERGE (a) -[:COMPETED_WITH]-> (b)


LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
MATCH (a:Finale {type:nodes.`type`, year:toInteger(nodes.year)}),
(b:Eurovision {year:toInteger(nodes.year)})
MERGE (a) -[:PART_OF]-> (b)


LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
MATCH (a:Song {name:nodes.Song, id:nodes.`songid`}),
(b:Song:Translation {name:nodes.`English translation`, id:nodes.songid})
MERGE (a) -[:TRANSLATION]-> (b)


LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
MATCH (a:Song {name:nodes.Song, id:nodes.`songid`}),
    (b:Language {name:nodes.`Song language1`}) 
FOREACH (n IN (CASE WHEN a IS NULL OR b IS NULL THEN [] ELSE [1] END) |
    MERGE (a) -[:AVAILABLE_IN]-> (b)
    )

LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
MATCH (a:Artist {name:nodes.Artist}),
(b:Song {name:nodes.Song, id:nodes.`songid`})
MERGE (a) -[:MADE]-> (b)


LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
MATCH (a:Artist {name:nodes.Artist}),
(b:Gender {gender:nodes.`Artist gender`})
MERGE (a) -[:GENDER]-> (b)

MATCH (a:Eurovision),
(b:Finale {year:toInteger(a.year)})
MERGE (a) -[:HAD_FINALE]-> (b)

LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
MATCH (a:Eurovision {year:toInteger(nodes.year)}),
(b:Country {name:nodes.`Host Country`})
MERGE (a) -[:HOSTED_BY]-> (b)


LOAD CSV WITH HEADERS FROM "file:///VotingRecords.csv" AS nodes
MATCH (a:Participant {country:nodes.country_from, year:toInteger(nodes.year), type:nodes.type}),
(b:Participant {country:nodes.country_to, year:toInteger(nodes.year), type:nodes.type})
MERGE (a) -[:VOTED_FOR {points:toFloat(nodes.points)}]-> (b)

LOAD CSV WITH HEADERS FROM "file:///GraphData.csv" AS nodes
FOREACH (n IN (CASE WHEN nodes.`Approximate Betting Prices` IN ['None'] OR nodes.`Approximate Betting Prices` IS NULL THEN [] ELSE [1] END) |
    MERGE (a:Participant {country:nodes.Country, year:toInteger(nodes.year), type:nodes.type})
    SET a.coefficient = toFloat(nodes.`Approximate Betting Prices`)
)
