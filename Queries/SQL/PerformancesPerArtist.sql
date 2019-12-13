SELECT name, Performances
FROM ( (SELECT  artistid, COUNT(artistid) as Performances
  FROM (SELECT artistid
    FROM Competed JOIN Song S on Competed.songid = S.songid)
  GROUP BY artistid
  ORDER BY Performances DESC) V
  JOIN
     (SELECT artistid, name
       FROM Artist) C on C.artistid = V.artistid)
