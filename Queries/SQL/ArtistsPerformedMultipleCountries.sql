SELECT name, PerformancesPerCountry
FROM (Artist
       JOIN
     (SELECT artistid, COUNT(artistid) as PerformancesPerCountry
      FROM (SELECT DISTINCT artistid,
                            country
            FROM (Competed
                   JOIN Song S on Competed.songid = S.songid)
           )
      GROUP BY artistid
      HAVING PerformancesPerCountry > 1
      ORDER BY PerformancesPerCountry DESC) V on Artist.artistid = V.artistid
       )

