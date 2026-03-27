Declare
@TopicID INT=3,
@FromDate DATETIME =NULL,
@ToDate DATETIME =NULL,
@GoogleTab INT=0,
@Source VARCHAR(100) ='Solr'
--@comment VARCHAR(300)='Total Records From Google',
--@URL NVARCHAR(MAX)=NULL

BEGIN

SET @FromDate= GETDATE()-60
SET @ToDate= GETDATE()+1

CREATE TABLE #TEMP_AOLog_Stats(
 SerpTab NVARCHAR(MAX),
 url NVARCHAR(MAX),
 Headline VARCHAR(MAX),
 Latestcomment NVARCHAR(MAX),
 ArticleDate SMALLDATETIME,
 IsEnriched INT,
 IsRelevant INT
)

CREATE TABLE #TEMP_AOLog_Details(
 SerpTab NVARCHAR(MAX),
 url NVARCHAR(MAX),
 Headline VARCHAR(MAX),
 Latestcomment NVARCHAR(MAX),
 ArticleDate SMALLDATETIME,
 IsEnriched INT,
 IsRelevant INT
)

DECLARE @SelectQuery NVARCHAR(MAX)='',@WhereQuery NVARCHAR(MAX)='',@StatsQuery NVARCHAR(MAX)='',@DetailsQuery NVARCHAR(MAX)='',@SourceID INT=0

IF(@Source='Google')
BEGIN
	SET @SourceID=2
END
ELSE IF(@Source='GoogleRecent')
BEGIN
	SET @SourceID=16
END
ELSE IF(@Source='Solr')
BEGIN
	SET @SourceID=8
END
ELSE 
BEGIN 
	SET @SourceID=0
END

--select * INTO #EQID_Table from [ArticleOnlineLog] where EQID in (select TagQueryID from [TagQuery] where TopicID=@TopicID  and PlatformID=1 )

--select * INTO #EQID_Table from [ArticleOnlineLog] WITH (NOLOCK)  where TopicID=@TopicID  

--SET @SelectQuery='
--with cte as(
--SELECT ROW_NUMBER() OVER (PARTITION BY url ORDER BY createdat DESC) AS rn,
--           SerpTab,url,Latestcomment,createdat	
--    FROM ADF_MDB_V2.[dbo].[ArticleOnlineLog] WITH (NOLOCK) 
--    WHERE EQID = '+Convert(VARCHAR(100),@EQID)+'
--	AND	Date >= '+'''' + Cast(@FromDate AS nvarchar(20)) + ''''+' and Date < '+'''' + Cast(@ToDate AS nvarchar(20)) + '''
--	)
--	select * from cte where rn=1
--	'

	declare @TagID INT=0
	select @TagID =TagID from Event WITH (NOLOCK)  where EventID=@TopicID


	;WITH CTE AS(
    SELECT ROW_NUMBER() OVER (PARTITION BY url ORDER BY createdat ASC) AS rn,Date,url,SerpTab	
    FROM [ArticleOnlineLog] AOL WITH (NOLOCK) 
    WHERE TopicID=@TagID  
	--EQID in (select EQID from #EQID_Table)
	AND (@SourceID =0 OR (SourceID=@SourceID))
	AND AOL.Date >= @FromDate
	AND AOL.Date <= @ToDate
	)
	select * INTO #TEMP1 from cte where rn=1;

	;WITH CTE2 AS(
   SELECT ROW_NUMBER() OVER (PARTITION BY url ORDER BY createdat desc) AS rn,url,comment,Date
    FROM [ArticleOnlineLog] AOL WITH (NOLOCK) 
    WHERE TopicID=@TagID  
	--EQID in (select EQID from #EQID_Table)
	AND (@SourceID =0 OR (SourceID=@SourceID))
	AND AOL.Date >= @FromDate
	AND AOL.Date <= @ToDate
	)
	select * INTO #TEMP2 from CTE2 where rn=1;

	CREATE TABLE #TEMP3
	(
	SerpTab VARCHAR(100),
	Url NVARCHAR(MAX),
	Headline VARCHAR(MAX),
	LatestComment VARCHAR(1000),
	ArticleDate Datetime,
	IsEnriched INT,
	IsRelevant INT

	)


	INSERT INTO  #TEMP3(SerpTab,Url,Headline,LatestComment,ArticleDate,IsEnriched,IsRelevant)
	
	SELECT distinct CASE WHEN LO.Tab=1 THEN 'All' WHEN LO.Tab=2 THEN  'News' END as  SerpTab, LO.Url, LO.Title AS Headline
	,'Inserted In DB' as LatestComment, LOP.Date AS ArticleDate
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
		AND (@SourceID =0 OR (LO.SourceID=@SourceID))
		AND LOP.Date >= @FromDate
		AND LOP.Date <= @ToDate
	
	UNION ALL

	SELECT #TEMP1.SerpTab,#TEMP1.Url,'' as Headline,#TEMP2.comment as LatestComment,#TEMP1.Date as ArticleDate,0 as IsEnriched,0 as IsRelevant  from #TEMP1
	INNER JOIN #TEMP2 ON #TEMP1.Url=#TEMP2.Url
	WHERE ISNULL(#TEMP2.comment,'') not in ('Inserted In DB','Solr Found Relevant')

	UNION ALL

	SELECT distinct CASE WHEN LO.Tab=1 THEN 'All' WHEN LO.Tab=2 THEN  'News' END as  SerpTab, LO.Url, LO.Title AS Headline
	,'Inserted In DB' as LatestComment, LOP.Date AS ArticleDate
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
		AND (@SourceID =0 OR (LO.SourceID=@SourceID))
		AND LOP.Date >= @FromDate
		AND LOP.Date <= @ToDate	
		AND ISNULL(#TEMP2.comment,'') in ('Inserted In DB','Solr Found Relevant')

		--select distinct LatestComment FROM #TEMP3
	
	
SET @SelectQuery=' SELECT distinct * from #TEMP3 WHERE ArticleDate >= '+'''' + Cast(Convert(DATETIME,@FromDate) AS nvarchar(20)) 
+ ''''+' and ArticleDate < '+'''' + Cast(Convert(DATETIME,@ToDate+1) AS nvarchar(20)) + '''	
'

--print @SelectQuery
IF(@SourceID IN (2,16))
BEGIN

	IF(@GoogleTab=0)
	BEGIN
		set @WhereQuery= @WhereQuery +'AND SERPTab in (''ALL'',''News'')'
	END
	IF(@GoogleTab=1)
	BEGIN
		set @WhereQuery= @WhereQuery +'AND SERPTab =''ALL'''
	END
	ELSE IF(@GoogleTab=2)
	BEGIN	
		set @WhereQuery=@WhereQuery+ 'AND SERPTab =''News'''
	END
END

SET @StatsQuery=@SelectQuery+' '+@WhereQuery

INSERT INTO #TEMP_AOLog_Stats
EXEC(@StatsQuery)

----print @StatsQuery

--IF(ISNULL(@comment,'')!='' and ISNULL(@comment,'')!='Total Records From Google')
--BEGIN	
--	set @WhereQuery=@WhereQuery+ 'AND ISNULL(Latestcomment,'''') = '+''''+@comment+''''
--END
--IF(ISNULL(@URL,'')!='')
--BEGIN	
--	--set @WhereQuery=@WhereQuery+ 'AND ISNULL(url,'''') = '+''''+@URL+''''
--	set @WhereQuery=@WhereQuery+ 'AND ISNULL(url,'''') in ( '+@URL+ ')'
--END

--SET @DetailsQuery=@SelectQuery+' '+@WhereQuery

--INSERT INTO #TEMP_AOLog_Details
--EXEC(@DetailsQuery)

--print @DetailsQuery

--SELECT 
--	CASE WHEN @GoogleTab=0 THEN 'All and News' 
--	WHEN @GoogleTab=1 THEN 'All'
--	WHEN @GoogleTab=2 THEN 'News' END as SERPTab,
--	Count(1) as [Total_Records_From_Google],	
--	Count(1)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Domain Extension' THEN 1 ELSE 0 END) AS [After_Removed_Due_To_Domain_Extension],
--    Count(1)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Domain Extension' THEN 1 ELSE 0 END)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Publication Exclusion List' THEN 1 ELSE 0 END) AS [After_Removed_Due_To_Publication_Exclusion_List],
--    Count(1)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Domain Extension' THEN 1 ELSE 0 END)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Publication Exclusion List' THEN 1 ELSE 0 END)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Publication Non News' THEN 1 ELSE 0 END) AS [After_Removed_Due_To_Publication_Non_News],
--    Count(1)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Domain Extension' THEN 1 ELSE 0 END)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Publication Exclusion List' THEN 1 ELSE 0 END)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Publication Non News' THEN 1 ELSE 0 END)- SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Exists In DB' THEN 1 ELSE 0 END) AS [After_Removed_Due_To_Exists_In_DB],
--    Count(1)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Domain Extension' THEN 1 ELSE 0 END)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Publication Exclusion List' THEN 1 ELSE 0 END)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Publication Non News' THEN 1 ELSE 0 END)- SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Exists In DB' THEN 1 ELSE 0 END)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Solr Found Not Relevant' THEN 1 ELSE 0 END) AS [After_Solr_Not_Relevant],	
--	Count(1)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Domain Extension' THEN 1 ELSE 0 END)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Publication Exclusion List' THEN 1 ELSE 0 END)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Publication Non News' THEN 1 ELSE 0 END)- SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Exists In DB' THEN 1 ELSE 0 END)-SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Solr Found Not Relevant' THEN 1 ELSE 0 END) -SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Solr Found Relevant' THEN 1 ELSE 0 END) AS [After_Solr_Relevant],		
--	SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Inserted In DB' THEN 1 ELSE 0 END) AS [Inserted_In_DB]	
--FROM #TEMP_AOLog_Stats
--WHERE rn = 1

--select 1 AS 'Dummy table'


--SELECT 
--	CASE WHEN @GoogleTab=0 THEN 'All and News' 
--	WHEN @GoogleTab=1 THEN 'All'
--	WHEN @GoogleTab=2 THEN 'News' END as SERPTab,
--	Count(1) as [Total_Records_From_Google],	
--	SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Domain Extension' THEN 1 ELSE 0 END) AS [Removed_Due_To_Domain_Extension],
--    SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Publication Exclusion List' THEN 1 ELSE 0 END) AS [Removed_Due_To_Publication_Exclusion_List],
--    SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Publication Non News' THEN 1 ELSE 0 END) AS [Removed_Due_To_Publication_Non_News],
--    SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Removed Due To Exists In DB' THEN 1 ELSE 0 END) AS [Removed_Due_To_Exists_In_DB],
--    SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Solr Found Not Relevant' THEN 1 ELSE 0 END) AS [Solr_Not_Relevant],	
--	SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Solr Found Relevant' THEN 1 ELSE 0 END) AS [Solr_Relevant],		
--	SUM(CASE WHEN ISNULL(Latestcomment,'') = 'Inserted In DB' THEN 1 ELSE 0 END) AS [Inserted_In_DB]	
--FROM #TEMP_AOLog_Stats
----WHERE rn = 1




IF(@SourceID IN (2,16))
BEGIN

	SELECT 
	    [filter_name],
		[filter_name] as [filter_value],
	    [filter_count]
	FROM (
	    SELECT 
	        COUNT(1) AS [Total Records From Google],	
	        SUM(CASE WHEN ISNULL(Latestcomment, '') = 'Removed Due To Domain Extension' THEN 1 ELSE 0 END) AS [Removed Due To Domain Extension],
	        SUM(CASE WHEN ISNULL(Latestcomment, '') = 'Removed Due To Publication Exclusion List' THEN 1 ELSE 0 END) AS [Removed Due To Publication Exclusion List],
	        SUM(CASE WHEN ISNULL(Latestcomment, '') = 'Removed Due To Publication Non News' THEN 1 ELSE 0 END) AS [Removed Due To Publication Non News],
	        SUM(CASE WHEN ISNULL(Latestcomment, '') = 'Removed Due To Exists In DB' THEN 1 ELSE 0 END) AS [Removed Due To Exists In DB],
	        SUM(CASE WHEN ISNULL(Latestcomment, '') = 'Solr Found Not Relevant' THEN 1 ELSE 0 END) AS [Solr Found Not Relevant],	
	        --SUM(CASE WHEN ISNULL(Latestcomment, '') = 'Solr Found Relevant' THEN 1 ELSE 0 END) AS [Solr Found Relevant],		
	        SUM(CASE WHEN ISNULL(Latestcomment, '') = 'Inserted In DB' THEN 1 ELSE 0 END) AS [Inserted In DB],	
			(select Count(1) from #TEMP_AOLog_Stats where IsEnriched=1) AS [Enriched],
			(select Count(1) from #TEMP_AOLog_Stats where IsRelevant=1) AS [Found Relevant]		
	    FROM #TEMP_AOLog_Stats
	) AS SourceTable
	UNPIVOT (
	    [filter_Count] FOR [filter_name] IN (
	        [Total Records From Google],
	        [Removed Due To Domain Extension],
	        [Removed Due To Publication Exclusion List],
	        [Removed Due To Publication Non News],
	        [Removed Due To Exists In DB],
	        [Solr Found Not Relevant],
	        --[Solr Found Relevant],
	        [Inserted In DB],
			[Enriched],
			[Found Relevant]
	    )
	) AS Unpvt;
END
ELSE IF(@SourceID IN (8))
BEGIN
	SELECT 
	    [filter_name],
		[filter_name] as [filter_value],
	    [filter_count]
	FROM (
	    SELECT 
	        COUNT(1) AS [Total Records From Solr],	
	        SUM(CASE WHEN ISNULL(Latestcomment, '') = 'Solr Found Not Relevant' THEN 1 ELSE 0 END) AS [Solr Found Not Relevant],	
	       -- SUM(CASE WHEN ISNULL(Latestcomment, '') = 'Solr Found Relevant' THEN 1 ELSE 0 END) AS [Solr Found Relevant],		
	        SUM(CASE WHEN ISNULL(Latestcomment, '') = 'Inserted In DB' THEN 1 ELSE 0 END) AS [Inserted In DB],	
			(select Count(1) from #TEMP_AOLog_Stats where IsEnriched=0) AS [Not Enriched],
			(select Count(1) from #TEMP_AOLog_Stats where IsEnriched=1) AS [Enriched],
			(select Count(1) from #TEMP_AOLog_Stats where IsRelevant=0) AS [Found Not Relevant]	,
			(select Count(1) from #TEMP_AOLog_Stats where IsRelevant=1) AS [Found Relevant]		
	    FROM #TEMP_AOLog_Stats
	) AS SourceTable
	UNPIVOT (
	    [filter_Count] FOR [filter_name] IN (
	        [Total Records From Solr],
	        [Solr Found Not Relevant],
	        --[Solr Found Relevant],
	        [Inserted In DB],
			[Not Enriched],
			[Enriched],
			[Found Not Relevant],
			[Found Relevant]
	    )
	) AS Unpvt;
END
--



--SELECT ROW_NUMBER() OVER (PARTITION BY url ORDER BY ArticleDate ASC) AS rn, SerpTab,url,Latestcomment,ArticleDate	
--FROM #TEMP_AOLog_Details
----where Url='https://bazaar.businesstoday.in/share-market/story/ongc-mrf-cochin-shipyard-and-ashok-leyland-among-stocks-turning-ex-dividend-next-week-1121707-2024-11-16'
----WHERE rn = 1
--order by Latestcomment

select Count(*) as NoOfRecords from #TEMP_AOLog_Details 

--EXEC USP_FindDifferenceInArticles @EQID=@EQID,@FromDate=@FromDate,@ToDate=@ToDate,@comment=@comment,@GoogleTab=@GoogleTab\

--WHERE rn = 1

drop table #TEMP_AOLog_Stats
drop table #TEMP_AOLog_Details
drop table #TEMP1,#TEMP2,#TEMP3
--drop table #EQID_Table
END
GO
