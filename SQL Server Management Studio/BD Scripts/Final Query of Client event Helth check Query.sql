

select  ClientID,e.EventID into #Data from EventUser eu with (nolock)
	INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON eu.EventID = e.EventID
	where UserID=634 AND IsActive=1
	order by ClientID

	--select count(distinct ClientID) as total_clients,count(distinct EventID) as total_events,0 as positive_events,0 as negative_events from #Data

CREATE TABLE #Events_HealthData(EventID INT,Article_Count_After_24hours_of_StartDate INT,Health VARCHAR(50),TotalRecords INT,InsertedInDB INT,FoundNotRelevant INT,Healthinserted VARCHAR(50),HealthRelevant VARCHAR(50))

INSERT INTO #Events_HealthData(EventID,Article_Count_After_24hours_of_StartDate,Health)
select  e.EventID, Count(*) AS Article_Count_After_24hours_of_StartDate
	,case when Count(*) >0 then 'Positive'
	ELSE 'Negative' END as Health
			FROM dbo.LinkOnline AO with (nolock)
			INNER JOIN [dbo].[LinkOnline_Processed] LP WITH (NOLOCK) ON LP.LOPID=AO.LOPID
			INNER JOIN [dbo].[TagLinkOnlineMap] tlom WITH (NOLOCK) ON tlom.LOID=AO.LOID 
			INNER JOIN [dbo].[TagLinkOnlineMapE] TLOME with(nolock) on TLOME.TLOMID=tlom.TLOMID
			--INNER JOIN [dbo].[LinkOnline_Enriched] LE with (nolock) ON LE.LOID = AO.LOID
			--INNER JOIN [dbo].[LinkOnline_EnrichedDetail] LED with (nolock) ON LED.TLOMEID = TLOME.TLOMEID
			INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
			WHERE e.EventID in (select distinct EventID from #Data)
			--AND (
			--		(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
			--	)
			and E.StartDate+1<=GETDATE()
			group BY e.EventID 


select ROW_NUMBER() OVER(ORDER BY EventID) as RN,* into #Events_PositiveHealthData from #Events_HealthData where Health='Positive'

declare @Count INT=0

select @Count =(select count(*) from #Events_PositiveHealthData)
WHILE(@Count>0)
BEGIN

DECLARE @TopicID INT,@FromDate DATETIME,@ToDate DATETIME

SELECT @TopicID = (select EventID from #Events_PositiveHealthData where RN=@Count)

SEt @FromDate=GETDATE()-7
SEt @ToDate=GETDATE()



BEGIN

--SET @FromDate= GETDATE()-7
--SET @ToDate= GETDATE()+1

CREATE TABLE #TEMP_AOLog_Stats(
 SerpTab NVARCHAR(MAX),
 url NVARCHAR(MAX),
 Headline VARCHAR(MAX),
 LatestCommentID TinyINT,
 ArticleDate SMALLDATETIME,
 IsEnriched INT,
 IsRelevant INT
)

CREATE TABLE #TEMP_AOLog_Details(
 SerpTab NVARCHAR(MAX),
 url NVARCHAR(MAX),
 Headline VARCHAR(MAX),
 LatestCommentID TinyINT,
 ArticleDate SMALLDATETIME,
 IsEnriched INT,
 IsRelevant INT
)

DECLARE @SelectQuery NVARCHAR(MAX)='',@WhereQuery NVARCHAR(MAX)='',@StatsQuery NVARCHAR(MAX)='',@DetailsQuery NVARCHAR(MAX)=''



	declare @TagID INT=0
	select @TagID =TagID from Event WITH (NOLOCK)  where EventID=@TopicID


	;WITH CTE AS(
    SELECT ROW_NUMBER() OVER (PARTITION BY url ORDER BY createdat ASC) AS rn,Date,url,SerpTab	
    FROM [ArticleOnlineLog_Shiv] AOL WITH (NOLOCK) 
    WHERE TopicID=@TagID  
	--EQID in (select EQID from #EQID_Table)
	--AND (@SourceID =0 OR (SourceID=@SourceID))
	AND AOL.Date >= @FromDate
	AND AOL.Date <= @ToDate
	)
	select * INTO #TEMP1 from cte where rn=1;

	;WITH CTE2 AS(
   SELECT ROW_NUMBER() OVER (PARTITION BY url ORDER BY createdat desc) AS rn,url,commentID,Date
    FROM [ArticleOnlineLog_Shiv] AOL WITH (NOLOCK) 
    WHERE TopicID=@TagID  
	--EQID in (select EQID from #EQID_Table)
	--AND (@SourceID =0 OR (SourceID=@SourceID))
	AND AOL.Date >= @FromDate
	AND AOL.Date <= @ToDate
	)
	select * INTO #TEMP2 from CTE2 where rn=1;

	CREATE TABLE #TEMP3
	(
	SerpTab VARCHAR(100),
	Url NVARCHAR(MAX),
	Headline VARCHAR(MAX),
	LatestCommentID TinyINT,
	ArticleDate Datetime,
	IsEnriched INT,
	IsRelevant INT

	)

	INSERT INTO  #TEMP3(SerpTab,Url,Headline,LatestCommentID,ArticleDate,IsEnriched,IsRelevant)
	
	SELECT distinct CASE WHEN LO.Tab=1 THEN 'All' WHEN LO.Tab=2 THEN  'News' END as  SerpTab, LO.Url, LO.Title AS Headline
	,1 as LatestCommentID, LOP.Date AS ArticleDate
	,CASE WHEN LE.LOEID >0 THEN 1 else 0 END as IsEnriched
	,CASE WHEN (e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1) THEN 1 ELSE 0 END as IsRelevant
    FROM [dbo].LinkOnline LO WITH (NOLOCK)
    INNER JOIN [dbo].[TagLinkOnlineMap] TLOM WITH (NOLOCK) ON TLOM.LOID = LO.LOID
    INNER JOIN [dbo].[TagLinkOnlineMapE] TLOME WITH (NOLOCK) ON TLOME.TLOMID = TLOM.TLOMID
	INNER JOIN [dbo].[LinkOnline_Processed] LOP WITH (NOLOCK) ON LOP.LOPID=LO.LOPID
	LEFT JOIN [dbo].[LinkOnline_Enriched] LE with (nolock) ON LE.LOID = LO.LOID
    LEFT JOIN [dbo].[LinkOnline_EnrichedDetail] LED WITH (NOLOCK) ON LED.TLOMEID = TLOME.TLOMEID
    LEFT JOIN [dbo].[mstPublication] PUB WITH (NOLOCK) ON PUB.PublicationID = LO.PublicationID
	INNER JOIN [dbo].[Event] E WITH (NOLOCK) ON E.TagID=TLOME.TagID
    WHERE E.EventID=@TopicID 
		--AND (@SourceID =0 OR (LO.SourceID=@SourceID))
		AND LOP.Date >= @FromDate
		AND LOP.Date <= @ToDate
	
	UNION ALL

	SELECT #TEMP1.SerpTab,#TEMP1.Url,'' as Headline,#TEMP2.CommentID as LatestCommentID,#TEMP1.Date as ArticleDate,0 as IsEnriched,0 as IsRelevant  from #TEMP1
	INNER JOIN #TEMP2 ON #TEMP1.Url=#TEMP2.Url
	WHERE ISNULL(#TEMP2.CommentID,0) not in (1,2)

	UNION ALL

	SELECT distinct CASE WHEN LO.Tab=1 THEN 'All' WHEN LO.Tab=2 THEN  'News' END as  SerpTab, LO.Url, LO.Title AS Headline
	,1 as LatestCommentID, LOP.Date AS ArticleDate
	,CASE WHEN LE.LOEID >0 THEN 1 else 0 END as IsEnriched
	,CASE WHEN (e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1) THEN 1 ELSE 0 END as IsRelevant
    FROM [dbo].LinkOnline LO WITH (NOLOCK)
	INNER JOIN #TEMP2 ON #TEMP2.Url=LO.Url
    INNER JOIN [dbo].[TagLinkOnlineMap] TLOM WITH (NOLOCK) ON TLOM.LOID = LO.LOID
    INNER JOIN [dbo].[TagLinkOnlineMapE] TLOME WITH (NOLOCK) ON TLOME.TLOMID = TLOM.TLOMID
	INNER JOIN [dbo].[LinkOnline_Processed] LOP WITH (NOLOCK) ON LOP.LOPID=LO.LOPID
	LEFT JOIN [dbo].[LinkOnline_Enriched] LE with (nolock) ON LE.LOID = LO.LOID
    LEFT JOIN [dbo].[LinkOnline_EnrichedDetail] LED WITH (NOLOCK) ON LED.TLOMEID = TLOME.TLOMEID
    LEFT JOIN [dbo].[mstPublication] PUB WITH (NOLOCK) ON PUB.PublicationID = LO.PublicationID
	INNER JOIN [dbo].[Event] E WITH (NOLOCK) ON E.TagID=TLOME.TagID
    WHERE E.EventID=@TopicID 
		--AND (@SourceID =0 OR (LO.SourceID=@SourceID))
		AND LOP.Date >= @FromDate
		AND LOP.Date <= @ToDate	
		AND ISNULL(#TEMP2.commentID,0) in (1,2)

		--select * FROM #TEMP3
	
	
SET @SelectQuery=' SELECT distinct * from #TEMP3 WHERE ArticleDate >= '+'''' + Cast(Convert(DATETIME,@FromDate) AS nvarchar(20)) 
+ ''''+' and ArticleDate < '+'''' + Cast(Convert(DATETIME,@ToDate+1) AS nvarchar(20)) + '''	
'



SET @StatsQuery=@SelectQuery+' '+@WhereQuery

INSERT INTO #TEMP_AOLog_Stats
EXEC(@StatsQuery)


CREATE TABLE #Records_from_all_sources(EventID INT,filter_name varchar(100),filter_value varchar(100),filter_count INT)


INSERT INTO #Records_from_all_sources( EventID,filter_name ,filter_value ,filter_count )
	SELECT 
		@TopicID,
	    [filter_name],
		[filter_name] as [filter_value],
	    [filter_count]
	FROM (
	    SELECT 
	        COUNT(1) AS [Total Records From All Sources],	
	        --SUM(CASE WHEN ISNULL(Latestcomment, '') = 'Removed Due To Domain Extension' THEN 1 ELSE 0 END) AS [Removed Due To Domain Extension],
	        SUM(CASE WHEN ISNULL(LatestCommentID, 0) = 3 THEN 1 ELSE 0 END) AS [Removed Due To Publication Exclusion List],
	        SUM(CASE WHEN ISNULL(LatestCommentID, 0) = 4 THEN 1 ELSE 0 END) AS [Removed Due To Publication Non News],
	        SUM(CASE WHEN ISNULL(LatestCommentID, 0) = 5 THEN 1 ELSE 0 END) AS [Removed Due To Exists In DB],
	        SUM(CASE WHEN ISNULL(LatestCommentID, 0) = 6 THEN 1 ELSE 0 END) AS [Solr Found Not Relevant],	
	        --SUM(CASE WHEN ISNULL(Latestcomment, 0) = 7 THEN 1 ELSE 0 END) AS [Solr Found Relevant],		
	        SUM(CASE WHEN ISNULL(LatestCommentID, 0) = 1 THEN 1 ELSE 0 END) AS [Inserted In DB],	
			(select Count(1) from #TEMP_AOLog_Stats where ISNULL(LatestcommentID, 0) = 1 and  IsEnriched=0) AS [Not Enriched],
			(select Count(1) from #TEMP_AOLog_Stats where IsEnriched=1) AS [Enriched],
			(select Count(1) from #TEMP_AOLog_Stats where ISNULL(LatestcommentID, 0) = 1 and IsEnriched=1 and  IsRelevant=0) AS [Found Not Relevant]	,
			(select Count(1) from #TEMP_AOLog_Stats where IsRelevant=1) AS [Found Relevant]			
	    FROM #TEMP_AOLog_Stats
	) AS SourceTable
	UNPIVOT (
	    [filter_Count] FOR [filter_name] IN (
	        [Total Records From All Sources],
	        --[Removed Due To Domain Extension],
	        [Removed Due To Publication Exclusion List],
	        [Removed Due To Publication Non News],
	        [Removed Due To Exists In DB],
	        [Solr Found Not Relevant],
	        --[Solr Found Relevant],
	        [Inserted In DB],
			[Not Enriched],
			[Enriched],
			[Found Not Relevant],
			[Found Relevant]
	    )
	) AS Unpvt;


--select * from #Records_from_all_sources


SELECT 
    src.EventID,TotalRecords.[Total Records],InsertedDB.[Inserted In DB],NotRelevant.[Found Not Relevant],
    CASE 
        WHEN (CAST(InsertedDB.[Inserted In DB] AS FLOAT) / TotalRecords.[Total Records]) < 0.2
        THEN 'Negative' 
        ELSE 'Positive' 
    END AS [Health_Inserted],
	 CASE 
        WHEN (CAST(NotRelevant.[Found Not Relevant] AS FLOAT) / InsertedDB.[Inserted In DB]) > 0.2
        THEN 'Negative' 
        ELSE 'Positive' 
    END AS [Health_Relevant]
INTO #DataOfEachEvent
FROM #Records_from_all_sources src
-- Get Total Records for each EventID
INNER JOIN (
    SELECT 
        EventID, 
        filter_count AS [Total Records]
    FROM #Records_from_all_sources
    WHERE filter_value = 'Total Records From All Sources'
) TotalRecords ON src.EventID = TotalRecords.EventID
-- Calculate Inserted In DB count for each EventID
INNER JOIN (
    SELECT 
        EventID, 
        filter_count AS [Inserted In DB]
    FROM #Records_from_all_sources
    WHERE filter_value = 'Inserted In DB'
) InsertedDB ON src.EventID = InsertedDB.EventID
INNER JOIN (
    SELECT 
        EventID, 
        filter_count AS [Found Not Relevant]
    FROM #Records_from_all_sources
    WHERE filter_value = 'Found Not Relevant'
) NotRelevant ON src.EventID = NotRelevant.EventID
GROUP BY src.EventID, TotalRecords.[Total Records], InsertedDB.[Inserted In DB],NotRelevant.[Found Not Relevant];


update #Events_HealthData set [TotalRecords]=ISNULL(a.[Total Records],0),[InsertedInDB]=ISNULL(a.[Inserted In DB],0),[FoundNotRelevant]=ISNULL(a.[Found Not Relevant],0),
[HealthInserted]=ISNULL(a.[Health_Inserted],'Negative'),[HealthRelevant]=ISNULL(a.[Health_Relevant],'Negative')
from #DataOfEachEvent a WITH(NOLOCK) 
inner JOIN #Events_HealthData b WITH(NOLOCK) on a.EventID=b.EventID where b.EventID=@TopicID

	


--drop table #Records_from_all_sources


drop table #DataOfEachEvent
drop table #Records_from_all_sources
drop table #TEMP_AOLog_Stats
drop table #TEMP_AOLog_Details
drop table #TEMP1,#TEMP2,#TEMP3

END

	
	SET @Count= @Count-1
	
END



select count(distinct b.ClientID) as total_clients,count(distinct b.EventID) as total_events,
COUNT(DISTINCT CASE  WHEN (ISNULL(Health, '') = 'Negative' OR ISNULL(Healthinserted, '') = 'Negative' OR ISNULL(HealthRelevant, '') = 'Negative' OR Health IS NULL) THEN b.EventID 
WHEN  (ISNULL(Health, '') = 'Negative' and Healthinserted IS NULL and HealthRelevant IS NULL ) THEN b.EventID 
WHEN Health IS NULL THEN b.EventID 
    END) AS negative_events,
COUNT(DISTINCT CASE  WHEN (ISNULL(Health, '') = 'Positive' and ( ISNULL(Healthinserted, '') = 'Positive' AND ISNULL(HealthRelevant, '') = 'Positive')) THEN b.EventID 
WHEN (ISNULL(Health, '') = 'Positive' and Healthinserted IS NULL and HealthRelevant IS NULL ) THEN b.EventID 
    END) AS positive_events
-- SUM(CASE WHEN (ISNULL(Health, '') = 'Negative' OR ISNULL(Healthinserted, '') = 'Negative' OR ISNULL(HealthRelevant, '') = 'Negative') THEN 1 
--	WHEN (ISNULL(Health, '') = 'Negative' and Healthinserted IS NULL and HealthRelevant IS NULL ) THEN 1 
--	WHEN Health IS NULL THEN 1 
-- ELSE 0 END) as negative_events,
--SUM(CASE WHEN (ISNULL(Health, '') = 'Positive' and ( ISNULL(Healthinserted, '') = 'Positive' and ISNULL(HealthRelevant, '') = 'Positive')) THEN 1 
--WHEN (ISNULL(Health, '') = 'Positive' and Healthinserted IS NULL and HealthRelevant IS NULL ) THEN 1 
--ELSE 0 END) as positive_events 
from #Events_HealthData a WITH(NOLOCK)
RIGHT JOIN #Data b WITH(NOLOCK) ON a.EventID=b.EventID

select * from #Events_HealthData a WITH(NOLOCK)
right JOIN #Data b WITH(NOLOCK) ON a.EventID=b.EventID







--drop table #Data
--DROP TABLE #Events_HealthData
--DROP TABLE #Events_PositiveHealthData