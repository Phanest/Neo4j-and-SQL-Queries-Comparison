
SELECT to_country, euroid, Points
FROM (SELECT to_country, euroid, Points, ROW_NUMBER() OVER (PARTITION BY euroid ORDER BY Points DESC) as rid
      FROM (SELECT to_country, euroid, SUM(points) as Points
            FROM Vote
            WHERE type = 'f'
            GROUP BY to_country, euroid)
     )
WHERE rid = 1