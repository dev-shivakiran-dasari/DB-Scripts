

DECLARE @COunt INT 

select @COunt = (select COUNT(1) from #Incidents )

WHILE(@COunt>0)
BEGIN 

	declare @incident_id int, @base_date DATETIME
	
	SELECT @incident_id=incident_id, @base_date=base_date from #Incidents where row_num=@COunt


	;WITH TwitterTemp AS
		(select tlom.TLTMID,EventID,TonalityID,Sentiment,t.tweet_id,t.LTID,t.THID,Tweet_Date  from LinkTweet t with (nolock) 
		INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID 
		INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
		INNER JOIN [dbo].[LinkTweet_Enriched] LE with (nolock) ON LE.LTID = t.LTID
		INNER JOIN [dbo].[LinkTweet_EnrichedDetail] LED with (nolock) ON LED.TLTMEID = TLOME.TLTMEID AND led.Is_Relevant_About_Topic=1
		INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID AND e.EventID=@incident_id
		where t.Tweet_Date >= @base_date AND t.Tweet_Date <= '2025-04-27 00:00:00' 
		)
		--CREATE TEMP TABLES START--
		insert into Z_DN_Twitter
		select t.TLTMID as twitter_id,t.tweet_id as tweet_id,@incident_id as incident_id,
		t.Tweet_Date as date_time,Sentiment as sentiment,tweet_conversationid,
		profile_handle,profile_name,profile_followerscount,profile_profilepicurl,
		engagement_retweetcount,engagement_replycount,engagement_likecount,engagement_quotecount,engagement_bookmarkcount,engagement_viewcount,
		engagement_retweetcount+engagement_replycount+engagement_likecount+engagement_quotecount as engagement_total,tonality,
		Profile_Category as UserProfileCategory,t.THID,t.LTID
		
		FROM TwitterTemp t with (nolock) 
		inner join LinkTweet_Detail ld with (nolock) on ld.LTID = t.LTID AND ld.Tweet_IsRetweeted = 0
		inner join TwitterHandle th with (nolock) on th.THID = t.THID
		inner join LinkTweet_Engagement LTE with (nolock) on LTE.LTID = t.LTID
		INNER JOIN [dbo].mstTonality_Enriched ME with (nolock) ON ME.TonalityID = t.TonalityID

	SET @COunt= @COunt-1

END

--drop table #Incidents
--drop table Z_DN_Twitter



--CREATE TABLE Z_DN_Twitter (
--	  ID INT PRIMARY KEY IDENTITY,
--    twitter_id INT,
--    tweet_id VARCHAR(100),
--    incident_id INT,
--    date_time SMALLDATETIME,
--    sentiment VARCHAR(20),
--    tweet_conversationid VARCHAR(100),
--    profile_handle NVARCHAR(2000),
--    profile_name NVARCHAR(2000),
--    profile_followerscount BIGINT,
--    profile_profilepicurl NVARCHAR(1000),
--    engagement_retweetcount BIGINT,
--    engagement_replycount BIGINT,
--    engagement_likecount BIGINT,
--    engagement_quotecount BIGINT,
--    engagement_bookmarkcount BIGINT,
--    engagement_viewcount BIGINT,
--    engagement_total BIGINT,
--    tonality VARCHAR(30),
--    UserProfileCategory VARCHAR(100),
--    THID INT,
--    LTID INT
--);


----CREATE TABLE #Incidents (
----    row_num INT,
----    incident_id INT,
----    base_date DATETIME
----);


--INSERT INTO #Incidents (row_num, incident_id, base_date)
--VALUES 
--(1,  40,  '2025-01-05 00:00'),
--(2,  10,  '2024-12-03 00:00'),
--(3,  108, '2025-01-28 00:00'),
--(4,  102, '2025-01-28 00:00'),
--(5,  101, '2025-01-28 00:00'),
--(6,  500, '2025-03-05 00:00'),
--(7,  99,  '2025-01-28 00:00'),
--(8,  80,  '2025-01-08 00:00'),
--(9,  382, '2025-02-28 00:00'),
--(10, 502, '2025-03-05 00:00'),
--(11, 666, '2025-03-20 00:00'),
--(12, 245, '2025-02-17 00:00'),
--(13, 421, '2025-02-27 00:00'),
--(14, 174, '2025-02-10 00:00'),
--(15, 957, '2025-04-22 00:00'),
--(16, 41,  '2025-01-05 00:00'),
--(17, 71,  '2025-01-08 00:00'),
--(18, 54,  '2025-01-06 00:00'),
--(19, 48,  '2025-01-05 00:00'),
--(20, 52,  '2025-01-05 00:00'),
--(21, 531, '2025-03-06 00:00'),
--(22, 263, '2025-02-17 00:00'),
--(23, 58,  '2025-01-06 00:00'),
--(24, 173, '2025-02-10 00:00'),
--(25, 55,  '2025-01-06 00:00');

