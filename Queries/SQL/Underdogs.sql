
--STEP BY STEP
--EVERYTHING SHOULD BE LOWERCASE

SELECT countryid, euroid, type FROM
    (SELECT countryid, CAST(euroid as integer) as euroid, type FROM Bets
        WHERE coefficient<=50) B
WHERE countryid IN (SELECT to_country FROM
    (SELECT  to_country
    FROM Vote
    WHERE Vote.euroid = B.euroid AND Vote.type = B.type
    GROUP BY Vote.to_country
    ORDER BY SUM(points) DESC
    LIMIT 10) C);

SELECT  to_country FROM Vote
WHERE Vote.euroid = 2 AND Vote.type = 'SF1'
GROUP BY Vote.to_country
ORDER BY SUM(points) DESC
LIMIT 10