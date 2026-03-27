
SELECT c.ClientID, c.Name as ClientName, e.EventID, 'Sentry' as ServiceName, COUNT(*) as SessionCount
        FROM UserEventLog uel WITH(NOLOCK)
        INNER JOIN dbo.[User] u WITH(NOLOCK) ON u.userID = uel.userID
        INNER JOIN SahadevC2.dbo.[Event] e WITH(NOLOCK) ON e.EventID = uel.RefID
        LEFT JOIN Client c WITH(NOLOCK) ON c.ClientID = e.ClientID
        WHERE uel.ServiceID = 2 
          AND uel.CreatedAt BETWEEN '2025-07-10 00:00:00' and '2025-07-15 23:59:00'
          --AND uel.UserID NOT IN (390,634,1638,1968,4091,4214,4243,4260,4636,4640,4688)
		  and uel.Source !='Web'
        GROUP BY c.ClientID, c.Name, e.EventID


		select * from UserEventLog where RefID=10 and ServiceID = 2 and  UserID NOT IN (390,634,1638,1968,4091,4214,4243,4260,4636,4640,4688)
		AND CreatedAt BETWEEN '2025-07-09 00:00:00' and '2025-07-15 23:59:00'

		select *from UserEventLog where  Source='Android'
		select distinct Source from UserEventLog 

select *from UserEventLog where  Source !='Web' AND CreatedAt > '2025-07-14 00:00:00'  order by CreatedAt desc

select u.UserName,uL.* from UserEventLog uL with(nolock)
INNER JOIN [User] u with(nolock) on uL.UserID=u.UserID
where  Source !='Web' AND ul.CreatedAt > '2025-07-14 00:00:00'  order by CreatedAt desc

		select distinct Source from UserEventLog 
