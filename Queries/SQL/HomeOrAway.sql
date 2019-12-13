--See whether countries are in HOME/AWAY region

SELECT C.country, C.euroid,
       CASE Cregion
         WHEN Hregion
           THEN 'HOME'
         ELSE 'AWAY'
         END REGION
FROM
  (SELECT songid, euroid, country, region as Cregion
  FROM Competed JOIN Country R on Competed.country = R.name) C
  JOIN
  (SELECT euroid, hostid, region as Hregion, year
  FROM Eurovision JOIN Country R on Eurovision.hostid = R.name) E ON C.euroid = E.euroid