
CREATE PROC [dbo].[USP_Notification_Conditional_YouTube]
AS 
BEGIN

CREATE TABLE #TempOutput (
    article_id INT,
    UserID VARCHAR(100),
    MediaTypeID INT,
    EntityName VARCHAR(100),
    incident_id INT,
    lstDeviceID VARCHAR(MAX),
    url VARCHAR(MAX),
    title NVARCHAR(MAX),
    description NVARCHAR(MAX),
    date_time NVARCHAR(100),
    author VARCHAR(100),
    sentiment VARCHAR(100),
    TopicName VARCHAR(100),
    TopicDescription VARCHAR(MAX),
    entity_name VARCHAR(100)
);


-- Insert into temporary table with UserID as comma-separated list
INSERT INTO #TempOutput (
    article_id,
    UserID,
    MediaTypeID,
    EntityName,
    incident_id,
    lstDeviceID,
    url,
    title,
    description,
    date_time,
    author,
    sentiment,
    TopicName,
    TopicDescription,
    entity_name
)


SELECT distinct
    tlym.TLYMID  as article_id,
    UD.UserID,
    1 as MediaTypeID,
    c.Name as EntityName,
    e.EventID as incident_id,
    DeviceID as lstDeviceID,
    y.Video_URL as url,
    y.Video_Title as title,
    LEFT(LE.[Summary], 200) + '...' as description,
    REPLACE(CONVERT(NVARCHAR, y.Video_Date, 106), ' ', '-') + ' | '+ LTRIM(RIGHT(CONVERT(VARCHAR(20), y.Video_Date, 100), 7)) as date_time,
    ISNULL(yc.Channel_Handle, 'NA') as author,
    LED.[Sentiment] as sentiment,
	case 							   
			when (ISNULL(e.EventName, 'Default') like '%General listening%') 
			then replace(ISNULL(e.EventName, 'Default'),'General listening','G.L.')
			else ISNULL(e.EventName, 'Default')
		end as TopicName,
    ISNULL(e.Description, 'Default') as TopicDescription,
    c.name as entity_name
	FROM [dbo].[LinkYouTube] y WITH (NOLOCK)
        INNER JOIN [dbo].[LinkYouTube_Detail] ld WITH (NOLOCK) ON ld.LYID = y.LYID
        INNER JOIN [dbo].[YouTubeChannel] yc WITH (NOLOCK) ON yc.YCID = y.YCID
        INNER JOIN [dbo].[LinkYouTube_Engagement] lye WITH (NOLOCK) ON lye.LYID = y.LYID
        INNER JOIN [dbo].[TagLinkYouTubeMap] tlym WITH (NOLOCK) ON tlym.LYID = y.LYID
        INNER JOIN [dbo].[LinkYouTube_Enriched] LE WITH (NOLOCK) ON LE.LYID = y.LYID
        INNER JOIN [dbo].[LinkYouTube_EnrichedDetail] LED WITH (NOLOCK) ON LED.TLYMID = tlym.TLYMID
        INNER JOIN [dbo].[LinkYouTube_Enriched_DiscourseCategory] LYEDC WITH (NOLOCK) ON LYEDC.LYEID = LE.LYEID
        INNER JOIN [dbo].[LinkYouTube_Enriched_VideoType] LYEV WITH (NOLOCK) ON LYEV.LYEID = LE.LYEID
        INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID = tlym.TagID
		INNER JOIN [dbo].client c WITH (NOLOCK) ON c.ClientID=e.ClientID
	INNER JOIN [dbo].EventUser eu WITH (NOLOCK) ON eu.EventID=e.EventID
INNER JOIN 
    SentryUser UD WITH(NOLOCK) on eu.UserID = UD.UserID AND UD.IsNotificationActive = 1 AND ISNULL(UD.[App_Version], '') <> '' 
	-- and app_version='Crisis'
INNER JOIN 
    Event_NotificationSetting ENS WITH(NOLOCK) on ENS.UserID = UD.UserID and ENS.EventID = eu.EventID  and ENS.PlatformID = 1 
                                              and ENS.IsActive = 1 and ENS.Platform_IsActive = 1 and ENS.Platform_Conditional=1 
outer apply(select MAX(ModifiedAt) as ModifiedAt from Event_NotificationSetting ENS WITH(NOLOCK) where   ENS.UserID=UD.UserID and ENS.EventID=eu.EventID 
and PlatformID=1 and ENS.IsActive=1 and ENS.Platform_IsActive=1 and ENS.Platform_Conditional=1  ) as LastModifiedAt

--WHERE e.EventID=3 
--		AND led.Is_Relevant_About_Topic=1
--		ORDER BY y.Video_Date desc



SELECT 
    article_id,
    STUFF((
        SELECT ',' + CONVERT(varchar(100), UserID)
        FROM (
            SELECT DISTINCT UserID,
                   ROW_NUMBER() OVER (ORDER BY UserID) AS rn
            FROM #TempOutput o2
            WHERE o2.article_id = o.article_id
            --ORDER BY UserID
        ) AS OrderedUserID
		ORDER BY rn
        FOR XML PATH('')), 1, 1, '') as UserID,
    MediaTypeID,
    EntityName,
    incident_id,
    STUFF((
        SELECT ',' + CONVERT(varchar(100), lstDeviceID)
        FROM (
            SELECT DISTINCT lstDeviceID,
                   ROW_NUMBER() OVER (ORDER BY UserID) AS rn
            FROM #TempOutput o2
            WHERE o2.article_id = o.article_id
            --ORDER BY lstDeviceID
        ) AS OrderedDeviceID
		ORDER BY rn
        FOR XML PATH('')), 1, 1, '') as lstDeviceID,
    url,
    title,
    description,
    date_time,
    author,
    sentiment,
    0 as NotificationTypeID,
    MAX(TopicName) as TopicName,
    MAX(TopicDescription) as TopicDescription,
    MAX(entity_name) as entity_name
FROM 
    #TempOutput o
GROUP BY 
    article_id,
    MediaTypeID,
    EntityName,
    incident_id,
    url,
    title,
    description,
    date_time,
    author,
    sentiment

-- Drop temporary table
DROP TABLE #TempOutput;

END