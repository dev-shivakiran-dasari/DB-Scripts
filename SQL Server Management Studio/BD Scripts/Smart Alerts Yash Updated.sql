SELECT 
    u.name AS UserName,
    ENSCD.UserID,
    --ENSCD.PlatformID AS MediaTypeID,
	CASE ENSCD.PlatformID 
        WHEN 1 THEN 'Online'
        WHEN 2 THEN 'Print'
        WHEN 3 THEN 'X'
        WHEN 4 THEN 'YouTube'
    END AS Platform,
    ENSCD.EventID AS TopicID,
    --COUNT(DISTINCT 
    --    CASE 
    --        WHEN ENLD.[Status] = 'Success'
    --         AND ENL.CreatedAt >= '2026-01-12 00:00:00'
    --        THEN ENLD.NLID 
    --    END
    --) AS Notifictaions_Sent,
    E.EventName,
	CONVERT(Date,E.StartDate) as StartDate,
	CONVERT(Date,E.EndDate) as EndDate,
    ENSCD.CriteriaJSON AS Condition,
    ENSCD.ConditionName,
	CONVERT(DATE,ENSCD.CreatedAt) AS Smart_Alert_CreatedAt,
    CONVERT(DATE,ENSCD.ModifiedAt) AS Smart_Alert_ModifiedAt,
	CASE WHEN ENL.CreatedAt IS NOT NULL THEN 'Yes' ELSE 'NO' END as Is_Notification_Sent,
	ENL.CreatedAt AS Notification_SentAt
FROM Event_NotificationSetting_ConditionalDetail ENSCD WITH (NOLOCK)
LEFT JOIN Event_NotificationSetting a ON a.UserID = ENSCD.UserID 
   AND a.EventID = ENSCD.EventID 
   AND a.PlatformID = ENSCD.PlatformID and ENSCD.IsActive=1 and ENSCD.Is_Deleted=0
LEFT JOIN Event_Notification_Log_Conditional_Detail ENLD WITH (NOLOCK)  
    ON ENLD.UserID = ENSCD.UserID 
   AND ENLD.TopicID = ENSCD.EventID 
   AND ENLD.MediaTypeID = ENSCD.PlatformID and [Status]='Success'

LEFT JOIN Event_Notification_Log_Conditional ENL WITH (NOLOCK)  
    ON ENLD.NLID = ENL.NLID

LEFT JOIN [User] u WITH (NOLOCK)  
    ON ENSCD.UserID = u.UserID

LEFT JOIN Event E WITH (NOLOCK)  
    ON E.EventID = ENSCD.EventID

WHERE ENSCD.UserID NOT IN (390,634,1638,1968,4091,4214,4243,4260,4636,4640,4688,427,5026)
AND ENL.CreatedAt >= '2026-01-12 00:00:00'

order by ENL.CreatedAt desc
--GROUP BY 
--    u.name,
--    ENSCD.UserID,
--    ENSCD.PlatformID,
--    ENSCD.EventID,
--    E.EventName,
--    ENSCD.CriteriaJSON,
--    ENSCD.ConditionName,
--	E.StartDate,
--	E.EndDate,
--	ENSCD.CreatedAt,
--	ENSCD.ModifiedAt

---------------------------------------------------------------------
--Event Wise 
---------------------------------------------------------------------

SELECT 
	E.EventName,
	ENLD.MediaTypeID,
    ENSCD.EventID AS TopicID,
	COUNT(distinct ENL.NLID) AS Notification_Generated_Count,
	'Smart Alert' as Notification_Type
FROM Event_NotificationSetting_ConditionalDetail ENSCD WITH (NOLOCK)
LEFT JOIN Event_NotificationSetting a ON a.UserID = ENSCD.UserID 
   AND a.EventID = ENSCD.EventID 
   AND a.PlatformID = ENSCD.PlatformID and ENSCD.IsActive=1 and ENSCD.Is_Deleted=0
LEFT JOIN Event_Notification_Log_Conditional_Detail ENLD WITH (NOLOCK)  
    ON ENLD.UserID = ENSCD.UserID 
   AND ENLD.TopicID = ENSCD.EventID 
   AND ENLD.MediaTypeID = ENSCD.PlatformID and [Status]='Success'
LEFT JOIN Event_Notification_Log_Conditional ENL WITH (NOLOCK)  
    ON ENLD.NLID = ENL.NLID
LEFT JOIN [User] u WITH (NOLOCK)  
    ON ENSCD.UserID = u.UserID
LEFT JOIN Event E WITH (NOLOCK)  
    ON E.EventID = ENSCD.EventID
WHERE ENSCD.UserID NOT IN (390,634,1638,1968,4091,4214,4243,4260,4636,4640,4688,427,5026)
AND ENL.CreatedAt >= '2026-01-01 00:00:00'
GROUP BY ENLD.MediaTypeID, ENSCD.EventID,E.EventName;

