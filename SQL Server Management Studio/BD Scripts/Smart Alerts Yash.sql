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

    COUNT(DISTINCT 
        CASE 
            WHEN ENLD.[Status] = 'Success'
             AND ENL.CreatedAt >= '2026-01-12 00:00:00'
            THEN ENLD.NLID 
        END
    ) AS CON_Count,

    E.EventName,
    ENSCD.CriteriaJSON AS Condition,
    ENSCD.ConditionName
FROM Event_NotificationSetting_ConditionalDetail ENSCD WITH (NOLOCK)

LEFT JOIN Event_Notification_Log_Conditional_Detail ENLD WITH (NOLOCK)  
    ON ENLD.UserID = ENSCD.UserID 
   AND ENLD.TopicID = ENSCD.EventID 
   AND ENLD.MediaTypeID = ENSCD.PlatformID

LEFT JOIN Event_Notification_Log_Conditional ENL WITH (NOLOCK)  
    ON ENLD.NLID = ENL.NLID

LEFT JOIN [User] u WITH (NOLOCK)  
    ON ENSCD.UserID = u.UserID

LEFT JOIN Event E WITH (NOLOCK)  
    ON E.EventID = ENSCD.EventID

WHERE ENSCD.UserID NOT IN (4091)

GROUP BY 
    u.name,
    ENSCD.UserID,
    ENSCD.PlatformID,
    ENSCD.EventID,
    E.EventName,
    ENSCD.CriteriaJSON,
    ENSCD.ConditionName;
