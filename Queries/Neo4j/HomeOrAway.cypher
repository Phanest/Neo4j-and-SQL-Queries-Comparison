//Whether a country is home or away
MATCH (r:Region) <-[:IN_REGION]- (a:Country) -[:PARTICIPATED_AS]-> () -[:PARTICIPATED_IN]-> () <-[:HAD_FINALE]- (e:Eurovision) -[:HOSTED_BY]-> (host:Country)  -[:IN_REGION]-> (hostr:Region)
RETURN a.name as country, r.region as region, host.name as host, hostr.region as `host region`,
    CASE WHEN r.region = hostr.region THEN 'HOME'
         ELSE 'AWAY' END as HomeOrAway