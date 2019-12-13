
SELECT from_country, COUNT(from_country) as Times
FROM (Vote V JOIN
     (SELECT to_country, euroid, type, Points
     FROM (SELECT to_country, euroid, type, Points, ROW_NUMBER() OVER (PARTITION BY euroid ORDER BY Points DESC) as rid
     FROM
          (SELECT to_country, euroid, type, SUM(points) as Points
          FROM Vote
          WHERE type = 'f'
          GROUP BY to_country, euroid)
       )
     WHERE rid = 1) J on V.to_country = J.to_country AND V.euroid = J.euroid AND V.type = J.type)
GROUP BY V.from_country
HAVING Times = (SELECT COUNT(N.from_country) FROM
     (SELECT DISTINCT C.from_country, C.euroid
     FROM Vote C WHERE C.to_country <> V.to_country AND C.from_country=V.from_country AND C.type = 'f') N )
ORDER BY Times DESC