

--SELECT  *
--    FROM Event_NotificationSetting WITH (NOLOCK)
--    WHERE  PlatformID=4 and Platform_IsActive=1 and Platform_Summarised =0 and EventID IN (
--2840
--,2998
--,3188
--,3204
--,3361
--,3485)
--	ORDER BY CreatedAt desc
    
--SELECT MediaTypeID, TopicID
--    FROM Event_Notification_Log_SI WITH (NOLOCK)
--    WHERE CreatedAt >= '2026-02-05 03:00:00' and MediaTypeID=4  and SummaryDetail_Json IS NOT NULL 
--    GROUP BY MediaTypeID,TopicID


SELECT 
    MediaTypeID,
    SUM(Count_SUM) AS Count_SUM,
    SUM(Count_CON) AS Count_CON,
    SUM(Count_AIH) AS Count_AIH
FROM (
    SELECT MediaTypeID, COUNT(*) AS Count_SUM, 0 AS Count_CON, 0 AS Count_AIH
    FROM Event_Notification_Log_SI WITH (NOLOCK)
    WHERE CreatedAt >= '2026-02-07 00:00:00' and SummaryDetail_Json IS NOT NULL 
    GROUP BY MediaTypeID

    UNION ALL

    SELECT MediaTypeID, 0, COUNT(*) AS Count_CON, 0
    FROM Event_Notification_Log_Conditional WITH (NOLOCK)
    WHERE CreatedAt >= '2026-02-07 00:00:00'
    GROUP BY MediaTypeID

    UNION ALL

    SELECT MediaTypeID, 0, 0, COUNT(*) AS Count_AIH
    FROM Event_Notification_Log WITH (NOLOCK)
    WHERE CreatedAt >= '2026-02-07 00:00:00'
    GROUP BY MediaTypeID
) t
GROUP BY MediaTypeID
ORDER BY MediaTypeID;
