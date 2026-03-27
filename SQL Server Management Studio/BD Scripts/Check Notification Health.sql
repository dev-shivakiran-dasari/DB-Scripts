---------------------------------------------------------------
-- 1. PRELOAD FILTER DATE (OPTIONAL VARIABLE)
---------------------------------------------------------------
DECLARE @StartDate DATETIME = '2025-07-17 00:00:00';


---------------------------------------------------------------
-- 2. TEMP TABLE FOR AIH COUNTS
---------------------------------------------------------------
IF OBJECT_ID('tempdb..#AIH') IS NOT NULL DROP TABLE #AIH;

SELECT 
    ENLD.UserID,
	U.Name as UserName,
    ENLD.MediaTypeID,
    ENL.TopicID,
	E.EventName,
    SUM(CASE WHEN ENLD.[Status] = 'Success' THEN 1 ELSE 0 END) AS AIH_Count
INTO #AIH
FROM Event_Notification_Log_Detail ENLD WITH (NOLOCK)
INNER JOIN Event_Notification_Log ENL WITH (NOLOCK)
    ON ENLD.NLID = ENL.NLID
INNER JOIN [User] U WITH (NOLOCK) ON U.UserID=ENLD.USerID
INNER JOIN EVENT E WITH (NOLOCK) ON E.EventID=ENL.TopicID
WHERE ENL.CreatedAt >= @StartDate
GROUP BY ENLD.UserID, ENLD.MediaTypeID, ENL.TopicID,EventName,U.Name;

select Top 10*  from #AIH
order by AIH_Count desc

select SUM(AIH_Count)  from #AIH



---------------------------------------------------------------
-- 3. TEMP TABLE FOR CONDITIONAL COUNTS
---------------------------------------------------------------
IF OBJECT_ID('tempdb..#CON') IS NOT NULL DROP TABLE #CON;

SELECT 
    ENLD.UserID,
	U.Name as UserName,
    ENLD.MediaTypeID,
    ENL.TopicID,
	E.EventName,
    SUM(CASE WHEN ENLD.[Status] = 'Success' THEN 1 ELSE 0 END) AS CON_Count
INTO #CON
FROM Event_Notification_Log_Conditional_Detail ENLD WITH (NOLOCK)
INNER JOIN Event_Notification_Log_Conditional ENL WITH (NOLOCK)
    ON ENLD.NLID = ENL.NLID
INNER JOIN [User] U WITH (NOLOCK) ON U.UserID=ENLD.USerID
INNER JOIN EVENT E WITH (NOLOCK) ON E.EventID=ENL.TopicID
WHERE ENL.CreatedAt >= @StartDate
GROUP BY ENLD.UserID, ENLD.MediaTypeID, ENL.TopicID,EventName,U.Name;

select Top 10 *  from #CON
order by CON_Count desc

select SUM(CON_Count)  from #CON

---------------------------------------------------------------
-- 4. TEMP TABLE FOR SUMMARY COUNTS
---------------------------------------------------------------
IF OBJECT_ID('tempdb..#SUM') IS NOT NULL DROP TABLE #SUM;

SELECT 
    ENLD.UserID,
	U.Name as UserName,
    ENLD.MediaTypeID,
    ENL.TopicID,
	E.EventName,
    SUM(CASE WHEN ENLD.[Status] = 'Success' 
              AND SummaryDetail_Json IS NOT NULL THEN 1 ELSE 0 END) AS SUM_Count
INTO #SUM
FROM Event_Notification_Log_SI_Detail ENLD WITH (NOLOCK)
INNER JOIN Event_Notification_Log_SI ENL WITH (NOLOCK)
    ON ENLD.NLID = ENL.NLID
INNER JOIN [User] U WITH (NOLOCK) ON U.UserID=ENLD.USerID
INNER JOIN EVENT E WITH (NOLOCK) ON E.EventID=ENL.TopicID
WHERE ENL.CreatedAt >= @StartDate
GROUP BY ENLD.UserID, ENLD.MediaTypeID, ENL.TopicID,EventName,U.Name;


select Top 10 *  from #SUM
order by SUM_Count desc
select SUM(SUM_Count) from #SUM

