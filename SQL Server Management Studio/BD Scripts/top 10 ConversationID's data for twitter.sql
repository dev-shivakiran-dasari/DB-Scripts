
declare 
--@Tweet_ConversationID varchar(100)='1872939446297141312',

@FromDate Datetime= '2024-12-18 16:43:00', 
@ToDate Datetime='2025-03-28 09:56:26',
@BaseDate datetime ='2024-11-18 00:00:00',
@topicid INT =12

	 CREATE TABLE #FinalOutput
	 (TweetID VARCHAR(100),
	 Tweet NVARCHAR(max),
	 Parent_TweetID VARCHAR(100),
	 Tweet_URL NVARCHAR(max),
	 Hierarchy_Order VARCHAR(500),
	 Tweet_ConversationID VARCHAR(500)
	 )
	
		--To Find the Conversation Thread Which Has Most Comments Start--------------------
	declare @No_of_tweets_in_a_thread_which_has_maximum_number_of_tweets INT
	 
	select top 10  TD.Tweet_ConversationID,count(TD.Tweet_ConversationID) as Count_ 
	INTO #Temp_TopTweet
	from LinkTweet T with (nolock) 
	INNER JOIN LinkTweet_Detail TD with (nolock) ON TD.LTID=T.LTID
	INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID 
	INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
	INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
	WHERE e.EventID=@TopicID AND t.Tweet_Date >=@FromDate AND t.Tweet_Date <= @ToDate AND TypeOfListening=3
	group by TD.Tweet_ConversationID
	order by 2 desc
	 
	SELECT  ROW_NUmber() OVER(order by Count_) as RN,* into #Top10Tweets from #Temp_TopTweet

	select * from #Top10Tweets

	Declare @Count INT =0,@recordsCount INT=0

	Select @count=(select Count(1) from #Top10Tweets)
	Select @recordsCount=(select Count(1) from #Top10Tweets)

	WHILE(@count>0)
	BEGIN
	

		declare @Tweet_ConversationID_Top varchar(max)='',@TreeInitialization INT =0	
		
		--select @Tweet_ConversationID_Top

		SET @Tweet_ConversationID_Top = (SELECT  Tweet_ConversationID from #Top10Tweets where RN=@count)

		--To Find the Conversation Thread Which Has Most Comments End--------------------
 
		--To Find the Comments Under @Tweet_ConversationID_Top  Start--------------------

		SET @TreeInitialization=(@recordsCount -(@count-1))

		
		select ROW_NUMBER() OVER (ORDER BY (SELECT Tweet_Date)) AS number, @Tweet_ConversationID_Top as Tweet_ConversationID,Tweet_Text,Tweet_ID,Tweet_RepliedToTweetID,0 as TwitterID,Tweet_Date
		,T.Tweet_URL
		into #TweetsData
		from LinkTweet T with (nolock) 
		INNER JOIN LinkTweet_Detail TD with (nolock) ON TD.LTID=T.LTID
		INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID 
		INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
		INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
		WHERE e.EventID=@TopicID AND t.Tweet_Date >=@FromDate AND t.Tweet_Date <= @ToDate
		AND Tweet_ConversationID = @Tweet_ConversationID_Top
		order by number asc

		--To Find the Comments Under @Tweet_ConversationID_Top  End--------------------
 
 
		--To Create Tree  Start--------------------

		--select * from #TweetsData
		 
		select Tweet_ID as cat_id,Tweet_text as cat_name,Tweet_RepliedToTweetID as parent_id,Tweet_URL,Tweet_ConversationID into #TweetsDataFinal  from #TweetsData
		 
		--select * from #TweetsDataFinal
		 
		;WITH cat_tree AS (
		  SELECT cat_id, cat_name, parent_id,Tweet_URL,Tweet_ConversationID,
		         1 AS level, CAST(@TreeInitialization AS varchar(90)) AS path		--TreeInitialization
		    FROM #TweetsDataFinal
		   WHERE parent_id IS NULL
		  UNION ALL
		  SELECT c.cat_id, c.cat_name, c.parent_id,c.Tweet_URL,c.Tweet_ConversationID,
		      ct.level + 1,
		      CAST(ct.path+'.'+CAST(
		       (row_number() OVER (ORDER BY ct.cat_id)) AS varchar) AS varchar(90))
			   
		    FROM #TweetsDataFinal c
		    JOIN cat_tree ct ON c.parent_id = ct.cat_id)
		 
		--SELECT * FROM cat_tree
		--ORDER BY path asc
		--option (maxrecursion 0);
		
		SELECT cat_id, cat_name, parent_id, path as Hierarchy_Order,ROW_NUMBER() OVER (ORDER BY (SELECT path)) AS number,Tweet_URL,Tweet_ConversationID  into #path FROM cat_tree
		ORDER BY path asc
		
		;WITH Hierarchy_CTE AS (
		    SELECT number, cat_id, cat_name, parent_id,Tweet_URL,Tweet_ConversationID,
		        Hierarchy_Order,
		        CAST('<r><n>' + REPLACE(Hierarchy_Order, '.', '</n><n>') + '</n></r>' AS XML) AS xml_data
				
		    FROM #path
		)
		SELECT 
		    ROW_NUMBER() OVER (ORDER BY Hierarchy_SortKey) AS number_sort,
		    number, cat_id, cat_name, parent_id,Tweet_URL,Tweet_ConversationID,
		    Hierarchy_Order  into #FinalData
		FROM (
		    SELECT number, cat_id, cat_name, parent_id,Tweet_URL,Tweet_ConversationID,
		        Hierarchy_Order,
		        (
		            SELECT STRING_AGG(FORMAT(CAST(x.value('.', 'int') AS INT), 'D10'), '.')
		            FROM xml_data.nodes('/r/n') AS T(x)
		        ) AS Hierarchy_SortKey
		    FROM Hierarchy_CTE
		) AS SortedData
		ORDER BY Hierarchy_SortKey;
		
		INSERT INTO #FinalOutput(TweetID ,	 Tweet ,	 Parent_TweetID ,	 Tweet_URL ,	 Hierarchy_Order,Tweet_ConversationID)
		select  cat_id as TweetID, cat_name as Tweet, parent_id as Parent_TweetID,Tweet_URL as Tweet_URL,    Hierarchy_Order,Tweet_ConversationID  from #FinalData

			drop table #TweetsData,#TweetsDataFinal,#path,#FinalData
			
				SET @count= @count-1
	END

	

	;WITH Hierarchy_CTE AS (
    SELECT TweetID ,	 Tweet ,	 Parent_TweetID ,	 Tweet_URL ,Tweet_ConversationID,
        Hierarchy_Order,
        CAST('<r><n>' + REPLACE(Hierarchy_Order, '.', '</n><n>') + '</n></r>' AS XML) AS xml_data
    FROM #FinalOutput
	)
	SELECT  TweetID ,	 Tweet ,	 Parent_TweetID ,	 Tweet_URL ,Tweet_ConversationID,
	    Hierarchy_Order
	FROM Hierarchy_CTE
	ORDER BY 
	    (
	        SELECT STRING_AGG(FORMAT(CAST(x.value('.', 'int') AS INT), 'D10'), '.')
	        FROM xml_data.nodes('/r/n') AS T(x)
	    );
	
	drop table #Temp_TopTweet,#Top10Tweets,#FinalOutput

	
	
	
	
	
	--select @No_of_tweets_in_a_thread_which_has_maximum_number_of_tweets as No_of_tweets_in_a_thread_which_has_maximum_number_of_tweets
	
	
	--;WITH hierarchy_paths AS (
	    
	--	 SELECT number_sort,number,cat_id as Tweet_ID,cat_name as Tweet_Text, CAST(number AS VARCHAR(255)) AS path
	
	--    FROM #FinalData
	
	--    WHERE parent_id IS NULL
	
	--    UNION ALL
	--    SELECT f.number_sort,f.number,f.cat_id as Tweet_ID,f.cat_name as Tweet_Text, CAST(CONCAT(path, ' > ', f.number) AS VARCHAR(255)) as path
	--    FROM #FinalData F
	--	JOIN hierarchy_paths hp ON f.parent_id = hp.Tweet_ID
		
		
	--)
	--SELECT Tweet_ID,Tweet_Text, path
	--FROM hierarchy_paths
	--order by number_sort;
	
	
	
	