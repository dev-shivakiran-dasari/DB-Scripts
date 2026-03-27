---------------------------------------------------------------
-- 1. PRELOAD FILTER DATE (OPTIONAL VARIABLE)
---------------------------------------------------------------
--DECLARE @StartDate DATETIME = '2026-01-12 00:00:00';

DECLARE @StartDate DATETIME = '2025-07-17 00:00:00';


---------------------------------------------------------------
-- 2. TEMP TABLE FOR AIH COUNTS
---------------------------------------------------------------
IF OBJECT_ID('tempdb..#AIH') IS NOT NULL DROP TABLE #AIH;

SELECT 
    ENLD.UserID,
    ENLD.MediaTypeID,
    ENL.TopicID,
    SUM(CASE WHEN ENLD.[Status] = 'Success' THEN 1 ELSE 0 END) AS AIH_Count,
    COUNT(*) AS AIH_Generated_Count
INTO #AIH
FROM Event_Notification_Log_Detail ENLD WITH (NOLOCK)
INNER JOIN Event_Notification_Log ENL WITH (NOLOCK)
    ON ENLD.NLID = ENL.NLID
WHERE ENL.CreatedAt >= @StartDate
AND UserID NOT IN (390,634,1638,1968,4091,4214,4243,4260,4636,4640,4688,427,5026)
GROUP BY ENLD.UserID, ENLD.MediaTypeID, ENL.TopicID;


---------------------------------------------------------------
-- 3. TEMP TABLE FOR CONDITIONAL COUNTS
---------------------------------------------------------------
--IF OBJECT_ID('tempdb..#CON') IS NOT NULL DROP TABLE #CON;

--SELECT 
--    ENLD.UserID,
--    ENLD.MediaTypeID,
--    ENL.TopicID,
--    SUM(CASE WHEN ENLD.[Status] = 'Success' THEN 1 ELSE 0 END) AS CON_Count,
--    COUNT(*) AS CON_Generated_Count
--INTO #CON
--FROM Event_Notification_Log_Conditional_Detail ENLD WITH (NOLOCK)
--INNER JOIN Event_Notification_Log_Conditional ENL WITH (NOLOCK)
--    ON ENLD.NLID = ENL.NLID
--WHERE ENL.CreatedAt >= @StartDate
--GROUP BY ENLD.UserID, ENLD.MediaTypeID, ENL.TopicID;


---------------------------------------------------------------
-- 4. TEMP TABLE FOR SUMMARY COUNTS
---------------------------------------------------------------
IF OBJECT_ID('tempdb..#SUM') IS NOT NULL DROP TABLE #SUM;

SELECT 
    ENLD.UserID,
    ENLD.MediaTypeID,
    ENL.TopicID,
    SUM(CASE WHEN ENLD.[Status] = 'Success' 
              AND SummaryDetail_Json IS NOT NULL THEN 1 ELSE 0 END) AS SUM_Count,
    SUM(CASE WHEN SummaryDetail_Json IS NOT NULL THEN 1 ELSE 0 END) AS SUM_Generated_Count
INTO #SUM
FROM Event_Notification_Log_SI_Detail ENLD WITH (NOLOCK)
INNER JOIN Event_Notification_Log_SI ENL WITH (NOLOCK)
    ON ENLD.NLID = ENL.NLID
WHERE ENL.CreatedAt >= @StartDate
and UserID NOT IN (390,634,1638,1968,4091,4214,4243,4260,4636,4640,4688,427,5026)
GROUP BY ENLD.UserID, ENLD.MediaTypeID, ENL.TopicID;


---------------------------------------------------------------
-- 5. MAIN QUERY
---------------------------------------------------------------
SELECT 
    b.UserName,
    OS,
    Event.EventName,
    CONVERT(DATE,Event.StartDate) as StartDate,
    CONVERT(DATE,Event.EndDate) as EndDate,
    Event.EventID,
    b.UserID,

    CASE a.PlatformID 
        WHEN 1 THEN 'Online'
        WHEN 2 THEN 'Print'
        WHEN 3 THEN 'X'
        WHEN 4 THEN 'YouTube'
    END AS Platform,

    a.Platform_IsActive,

    CASE 
        WHEN Platform_AsItHappens = 1 THEN 'AsItHappens'
        WHEN Platform_Summarised = 1 THEN 'Summarised'
        WHEN Platform_Conditional = 1 THEN 'Conditional'
    END AS Notification_Type,

    a.Platform_SummarisedInterval AS Interval,

    CASE 
        WHEN ISNULL(Platform_AsItHappens,0) = 1 THEN ISNULL(AIH.AIH_Count,0)
        WHEN ISNULL(Platform_Summarised,0) = 1 THEN ISNULL(SM.SUM_Count,0)
        --WHEN ISNULL(Platform_Conditional,0) = 1 THEN ISNULL(CN.CON_Count,0)
    END AS Notification_Count,

    CASE 
        WHEN ISNULL(Platform_AsItHappens,0) = 1 THEN ISNULL(AIH.AIH_Generated_Count,0)
        WHEN ISNULL(Platform_Summarised,0) = 1 THEN ISNULL(SM.SUM_Generated_Count,0)
        --WHEN ISNULL(Platform_Conditional,0) = 1 THEN ISNULL(CN.CON_Generated_Count,0)
    END AS Notification_Generated_Count,

    CONVERT(DATE,a.CreatedAt) AS Notification_Setting_CreatedAt,
    CONVERT(DATE,a.ModifiedAt) AS Notification_Setting_ModifiedAt

FROM Event_NotificationSetting a WITH (NOLOCK)
INNER JOIN [User] b WITH (NOLOCK) 
    ON a.UserID = b.UserID
INNER JOIN Event WITH (NOLOCK) 
    ON a.EventID = Event.EventID
INNER JOIN SentryUser WITH (NOLOCK) 
    ON a.UserID = SentryUser.UserID

LEFT JOIN #AIH AIH 
    ON AIH.UserID = a.UserID 
    AND AIH.MediaTypeID = a.PlatformID
    AND AIH.TopicID = a.EventID

--LEFT JOIN #CON CN
--    ON CN.UserID = a.UserID 
--    AND CN.MediaTypeID = a.PlatformID
--    AND CN.TopicID = a.EventID

LEFT JOIN #SUM SM
    ON SM.UserID = a.UserID 
    AND SM.MediaTypeID = a.PlatformID
    AND SM.TopicID = a.EventID

WHERE 
    (a.CreatedAt >= @StartDate 
    OR a.ModifiedAt >= @StartDate)
	and b.UserID NOT IN (390,634,1638,1968,4091,4214,4243,4260,4636,4640,4688,427,5026)

ORDER BY b.UserName;


drop table #AIH
drop table #SUM