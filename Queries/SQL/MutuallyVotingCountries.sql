
SELECT DISTINCT from_country, to_country
FROM Vote V
WHERE
  (SELECT COUNT(euroid) FROM
    (SELECT DISTINCT euroid, type
    FROM Vote A
    WHERE A.to_country = V.from_country --Gives us all the times (euroid and finale) where V.from_country was a contestant
    INTERSECT --All the euroid and finale where from_country was a contestant and to_country voted
    SELECT DISTINCT euroid, type
    FROM Vote B
    WHERE B.from_country = V.to_country) ) --Gives us all the times V.to_country was a voter
    =
  (SELECT COUNT(C.to_country) --The amount of times to_country voted for from_country
    FROM Vote C
    WHERE C.from_country=V.to_country AND C.to_country=V.from_country)
  AND
    (SELECT COUNT(euroid) FROM
    (SELECT DISTINCT euroid, type
    FROM Vote A
    WHERE A.to_country = V.to_country --Gives us all the times (euroid and finale) where V.to_country was a contestant
    INTERSECT --All the euroid and finale where to_country was a contestant and from_country voted
    SELECT DISTINCT euroid, type
    FROM Vote B
    WHERE B.from_country = V.from_country) ) --Gives us all the times V.to_country was a voter
    =
  (SELECT COUNT(C.to_country) --The amount of times to_country voted for from_country
    FROM Vote C
    WHERE C.from_country=V.from_country AND C.to_country=V.to_country)

SELECT euroid, type
FROM Vote
WHERE to_country='Albania' AND from_country='Macedonia'