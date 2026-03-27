select distinct U.UserID,U.UserName,E.EventID,E.EventName,
case when PlatformID=1 and Platform_IsActive=1 then 'Online'
 when PlatformID=2 and Platform_IsActive=1 then 'Print'
 when PlatformID=3 and Platform_IsActive=1 then 'X'
 when PlatformID=4 and Platform_IsActive=1 then 'YouTube' End as [Platform],
 Platform_SummarisedInterval as Interval
 ,Platform_IsActive 
from Event_NotificationSetting ENS
INNER JOIN Event E on E.EventID=ENS.EventID
INNER JOIN [User] U on U.UserID=ENS.UserID
where ENS.Platform_Summarised=1
order by U.UserName


--select * from Event_NotificationSetting where EventID=1408 and UserID=4640