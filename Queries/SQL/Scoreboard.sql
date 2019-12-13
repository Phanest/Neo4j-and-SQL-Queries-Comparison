--SCOREBOARD

--SELECT Country_to, SUM(POINTS) as Points FROM (VOTE JOIN
--(SELECT euroid, type FROM (FINALE JOIN EUROVISION) WHERE EUROVISION.year = year AND FINALE.type = type )
--GROUP BY Country_to
--ORDER BY DESC Points

--STEP BY STEP
--EVERYTHING SHOULD BE LOWERCASE
--TEST UPPER JOIN

SELECT to_country, sum(points) AS Points
  FROM (VOTE V JOIN
    (SELECT E.euroid, F.type FROM (Finale F JOIN Eurovision E on F.euroid = E.euroid)
      WHERE E.year = 2009 AND F.type = 'f') F on V.euroid = F.euroid AND V.type = F.type)
  GROUP BY to_country
  ORDER BY Points DESC