select b.UserName,OS,EventName,Event.StartDate,Event.EndDate,
Event.EventID,b.UserID,
case when a.PlatformID =1 then 'Online'
when a.PlatformID =2 then 'Print'
when a.PlatformID =3 then 'X'
when a.PlatformID =4 then 'YouTube'
END as 'Platform'
,a.Platform_IsActive
,case when Platform_AsItHappens=1 then 'AsItHappens'
when Platform_Summarised=1 then 'Summarised'
when Platform_Conditional=1 then 'Conditional' 
end as Notification_Type
,Platform_SummarisedInterval as Interval
,case when Platform_AsItHappens=1 then AIH_Count
when Platform_Summarised=1 then SUM_Count
when Platform_Conditional=1 then CON_Count 
end as Notification_Count,
,case when Platform_AsItHappens=1 then AIH_Generated_Count
when Platform_Summarised=1 then SUM_Generated_Count
when Platform_Conditional=1 then CON_Generated_Count
end as Notification_Generated_Count
--,AIH_Count
--,CON_Count
--,SUM_Count
,a.CreatedAt as Notification_Setting_CreatedAt
,a.ModifiedAt as Notification_Setting_ModifiedAt
from Event_NotificationSetting a
inner join [User] b on a.UserID=b.UserID
inner join Event on a.EventID=Event.EventID
inner join SentryUser on a.UserID=SentryUser.UserID
OUTER APPLY (
select COUNT(1) as AIH_Count from Event_Notification_Log_Detail ENLD
INNER JOIN Event_Notification_Log ENL on ENLD.NLID=ENL.NLID and ENLD.UserID =a.UserID and Platform_AsItHappens=1 and ENLD.MediaTypeID=a.PlatformID 
and ENL.TopicID=a.EventID and ENLD.[Status]='Success' and ENL.CreatedAt >='2025-07-17 00:00:00'
) as AIH
OUTER APPLY (
select COUNT(1) as CON_Count from Event_Notification_Log_Conditional_Detail ENLD_con
INNER JOIN Event_Notification_Log_Conditional ENL_con on ENLD_con.NLID=ENL_con.NLID and ENLD_con.UserID =a.UserID and Platform_Conditional=1 and ENLD_con.MediaTypeID=a.PlatformID
and ENL_con.TopicID=a.EventID and ENLD_con.[Status]='Success'  and ENL_con.CreatedAt >='2025-07-17 00:00:00'
) as Conditional
OUTER APPLY (
select COUNT(1) as SUM_Count from Event_Notification_Log_SI_Detail ENLD_Sum
INNER JOIN Event_Notification_Log_SI ENL_Sum on ENLD_Sum.NLID=ENL_Sum.NLID and ENLD_Sum.UserID =a.UserID and Platform_Summarised=1 and ENLD_Sum.MediaTypeID=a.PlatformID  
and ENL_Sum.TopicID=a.EventID and ENLD_Sum.[Status]='Success' and SummaryDetail_Json is not NULL and ENL_Sum.CreatedAt >='2025-07-17 00:00:00'
) as Summerized
OUTER APPLY (
select COUNT(1) as AIH_Generated_Count from Event_Notification_Log_Detail ENLD
INNER JOIN Event_Notification_Log ENL on ENLD.NLID=ENL.NLID and ENLD.UserID =a.UserID and Platform_AsItHappens=1 and ENLD.MediaTypeID=a.PlatformID 
and ENL.TopicID=a.EventID  and ENL.CreatedAt >='2025-07-17 00:00:00'
) as AIH_Generated_Count
OUTER APPLY (
select COUNT(1) as CON_Generated_Count from Event_Notification_Log_Conditional_Detail ENLD_con
INNER JOIN Event_Notification_Log_Conditional ENL_con on ENLD_con.NLID=ENL_con.NLID and ENLD_con.UserID =a.UserID and Platform_Conditional=1 and ENLD_con.MediaTypeID=a.PlatformID
and ENL_con.TopicID=a.EventID   and ENL_con.CreatedAt >='2025-07-17 00:00:00'
) as Conditional_Generated_Count
OUTER APPLY (
select COUNT(1) as SUM_Generated_Count from Event_Notification_Log_SI_Detail ENLD_Sum
INNER JOIN Event_Notification_Log_SI ENL_Sum on ENLD_Sum.NLID=ENL_Sum.NLID and ENLD_Sum.UserID =a.UserID and Platform_Summarised=1 and ENLD_Sum.MediaTypeID=a.PlatformID  
and ENL_Sum.TopicID=a.EventID and SummaryDetail_Json is not NULL and ENL_Sum.CreatedAt >='2025-07-17 00:00:00'
) as Summerized_Generated_Count
where a.CreatedAt >='2025-07-17 00:00:00' or a.ModifiedAt >='2025-07-17 00:00:00'
order by b.UserName

