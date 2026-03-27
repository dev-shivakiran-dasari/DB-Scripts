

--select *from event  where eventid=99

--EXEC [dbo].[USP_API_SentryV2_Twitter_FetchLanding_Optimized_StatCards] 
DECLARE
@TopicID INT = 99,
@BaseDate datetime = '2025-01-28 00:00:00',
@FromDate datetime = '2025-01-28 00:00:00',
@ToDate datetime = '2025-02-26 09:56:26'


BEGIN

		DECLARE @CompareFromDate datetime,@CompareToDate datetime
		
		SET @CompareToDate = @FromDate

		SET @CompareFromDate = (SELECT DATEADD(MINUTE, -DATEDIFF(MINUTE, @FromDate, @ToDate), @FromDate))

		Print  @CompareFromDate
		Print  @CompareToDate

		select tlom.TLTMID as twitter_id,t.tweet_id as tweet_id,e.EventID as incident_id,
		t.Tweet_URL as url,t.Tweet_Text as description,t.Tweet_Date as date_time,Sentiment as sentiment,tweet_conversationid,
		profile_handle,profile_name,profile_followerscount,profile_followingcount,profile_tweetscount,profile_listscount,profile_isprotected,
		profile_isverified,profile_verifiedtype,profile_profilepicurl,profile_externalUrl,profile_description,profile_location,
		engagement_retweetcount,engagement_replycount,engagement_likecount,engagement_quotecount,engagement_bookmarkcount,engagement_viewcount,
		tonality,t.LTID,th.THID,LED.TonalityID,tlom.TLTMID,e.EventID,t.Tweet_URL,t.Tweet_Text,t.Tweet_Date,Profile_Category
		into #TwitterTemp from LinkTweet t with (nolock) 
		INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
		INNER JOIN [dbo].[LinkTweet_Enriched] LE with (nolock) ON LE.LTID = t.LTID
		INNER JOIN [dbo].[LinkTweet_EnrichedDetail] LED with (nolock) ON LED.TLTMEID = TLOME.TLTMEID AND led.Is_Relevant_About_Topic=1
		inner join LinkTweet_Detail ld with (nolock) on ld.LTID = t.LTID AND ld.Tweet_IsRetweeted = 0
		inner join TwitterHandle th with (nolock) on th.THID = t.THID
		inner join LinkTweet_Engagement LTE with (nolock) on LTE.LTID = t.LTID
		INNER JOIN [dbo].mstTonality_Enriched ME with (nolock) ON ME.TonalityID = LED.TonalityID
		INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID AND e.EventID=@TopicID
		where t.Tweet_Date >= @BaseDate AND t.Tweet_Date <= @ToDate 

		select LM.MentionValue,MKID,LM.LTID into #TwitterMentionTemp from LinkTweet_Mention LM with (nolock) 
		inner join #TwitterTemp on #TwitterTemp.LTID = LM.LTID

		--CREATE TEMP TABLES START--
		select t.TLTMID as twitter_id,t.tweet_id as tweet_id,t.EventID as incident_id,
		t.Tweet_URL as url,t.Tweet_Text as description,t.Tweet_Date as date_time,Sentiment as sentiment,tweet_conversationid,
		profile_handle,profile_name,profile_followerscount,profile_followingcount,profile_tweetscount,profile_listscount,profile_isprotected,
		profile_isverified,profile_verifiedtype,profile_profilepicurl,profile_externalUrl,profile_description,profile_location,
		engagement_retweetcount,engagement_replycount,engagement_likecount,engagement_quotecount,engagement_bookmarkcount,engagement_viewcount,
		engagement_retweetcount+engagement_replycount+engagement_likecount+engagement_quotecount as engagement_total,tonality,
		stuff((SELECT ',' + MentionValue 
				FROM #TwitterMentionTemp
				WHERE #TwitterMentionTemp.MKID = 2 AND LTID=t.LTID
				FOR XML PATH('')),1,1,'') AS Mentioned_Hashtags,
		stuff((SELECT ',' + MentionValue
				FROM #TwitterMentionTemp  with (nolock)
				WHERE #TwitterMentionTemp.MKID = 1 AND LTID=t.LTID
				FOR XML PATH('')),1,1,'') AS Mentioned_Handles,
		stuff((SELECT ',' + MentionValue
				FROM #TwitterMentionTemp  with (nolock)
				WHERE #TwitterMentionTemp.MKID = 3 AND LTID=t.LTID
				FOR XML PATH('')),1,1,'') AS Mentioned_Hyperlinks,
		Profile_Category as UserProfileCategory,t.THID
		into #Temp_BaseDate_ToDate
		FROM #TwitterTemp t with (nolock) 
		--inner join LinkTweet_Detail ld with (nolock) on ld.LTID = t.LTID AND ld.Tweet_IsRetweeted = 0
		--inner join TwitterHandle th with (nolock) on th.THID = t.THID
		--inner join LinkTweet_Engagement LTE with (nolock) on LTE.LTID = t.LTID
		--INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
		--INNER JOIN [dbo].[LinkTweet_Enriched] LE with (nolock) ON LE.LTID = t.LTID
		--INNER JOIN [dbo].[LinkTweet_EnrichedDetail] LED with (nolock) ON LED.TLTMID = t.TLTMID AND led.Is_Relevant_About_Topic=1
		--INNER JOIN [dbo].mstTonality_Enriched ME with (nolock) ON ME.TonalityID = t.TonalityID
		--INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID AND e.EventID=@TopicID 
		 
		drop table #TwitterTemp,#TwitterMentionTemp

		CREATE NONCLUSTERED INDEX ix_Temp_BaseDate_ToDate ON #Temp_BaseDate_ToDate (date_time)
		CREATE NONCLUSTERED INDEX ix_Temp_BaseDate_ToDate_THID ON #Temp_BaseDate_ToDate (THID)

		select THID
		into #Temp_BaseDate_FromDate
		FROM #Temp_BaseDate_ToDate
		WHERE date_time >= @BaseDate AND date_time <= @FromDate

		--CREATE NONCLUSTERED INDEX ix_Temp_BaseDate_FromDate ON #Temp_BaseDate_FromDate (date_time)
		CREATE NONCLUSTERED INDEX ix_Temp_BaseDate_FromDate_THID ON #Temp_BaseDate_FromDate (THID)

		
		select twitter_id,tweet_id,incident_id,url,description,date_time,sentiment,tweet_conversationid,
		profile_handle,profile_name,profile_followerscount,profile_followingcount,profile_tweetscount,profile_listscount,profile_isprotected,
		profile_isverified,profile_verifiedtype,profile_profilepicurl,profile_externalUrl,profile_description,profile_location,
		engagement_retweetcount,engagement_replycount,engagement_likecount,engagement_quotecount,engagement_bookmarkcount,engagement_viewcount,tonality,
		Mentioned_Hashtags,Mentioned_Handles,Mentioned_Hyperlinks,UserProfileCategory,engagement_total,THID
		into #Temp_FromDate_ToDate
		FROM #Temp_BaseDate_ToDate
		WHERE date_time >= @FromDate AND date_time <= @ToDate

		CREATE NONCLUSTERED INDEX ix_Temp_FromDate_ToDate ON #Temp_FromDate_ToDate (date_time)
		CREATE NONCLUSTERED INDEX ix_Temp_FromDate_ToDate_THID ON #Temp_FromDate_ToDate (THID)

		select twitter_id,tweet_id,incident_id,url,description,date_time,sentiment,tweet_conversationid,
		profile_handle,profile_name,profile_followerscount,profile_followingcount,profile_tweetscount,profile_listscount,profile_isprotected,
		profile_isverified,profile_verifiedtype,profile_profilepicurl,profile_externalUrl,profile_description,profile_location,
		engagement_retweetcount,engagement_replycount,engagement_likecount,engagement_quotecount,engagement_bookmarkcount,engagement_viewcount,tonality,
		Mentioned_Hashtags,Mentioned_Handles,Mentioned_Hyperlinks,UserProfileCategory,engagement_total,THID
		into #Temp_CompareFromDate_CompareToDate
		FROM #Temp_BaseDate_ToDate
		WHERE date_time >= @CompareFromDate AND date_time <= @CompareToDate
		
		CREATE NONCLUSTERED INDEX ix_Temp_CompareFromDate_CompareToDate ON #Temp_CompareFromDate_CompareToDate (date_time)
		CREATE NONCLUSTERED INDEX ix_#Temp_CompareFromDate_CompareToDate_THID ON #Temp_CompareFromDate_CompareToDate (THID)

		--CREATE TEMP TABLES END--
		
		--tweetsTimeline START
		CREATE TABLE #tweetsTimeline1(
			x_axis_name  VARCHAR(4) NOT NULL PRIMARY KEY
			,y_axis_value INTEGER  NOT NULL
		)
		INSERT INTO #tweetsTimeline1(x_axis_name,y_axis_value) VALUES ('9:15',100)
		INSERT INTO #tweetsTimeline1(x_axis_name,y_axis_value) VALUES ('9:25',150)
		INSERT INTO #tweetsTimeline1(x_axis_name,y_axis_value) VALUES ('9:35',170)

		select * from #tweetsTimeline1
		drop table #tweetsTimeline1
		--tweetsTimeline END


		--twitter_stats START

		--Total Tweets - 173 / 405 +31%
		DECLARE @Total_Tweets_BaseDate_ToDate bigint,@Total_Tweets_FromDate_ToDate bigint,@Total_Tweets_CompareFromDate_CompareToDate bigint,@Total_Tweets_Percentage bigint

		SET @Total_Tweets_BaseDate_ToDate = (SELECT Count(twitter_id) from #Temp_BaseDate_ToDate)
		SET @Total_Tweets_CompareFromDate_CompareToDate = (SELECT Count(twitter_id) from #Temp_CompareFromDate_CompareToDate)
		SET @Total_Tweets_FromDate_ToDate = (SELECT Count(twitter_id) from #Temp_FromDate_ToDate)
		SET @Total_Tweets_Percentage =isnull( (SELECT round(((convert(decimal(18,2),@Total_Tweets_FromDate_ToDate-@Total_Tweets_CompareFromDate_CompareToDate))*100/convert(decimal(18,2),nullif(@Total_Tweets_CompareFromDate_CompareToDate,0))),0)),0)


		--Total Reach - 26.5M / 67M -13%
		DECLARE @Total_Reach_BaseDate_ToDate bigint,@Total_Reach_FromDate_ToDate bigint,@Total_Reach_CompareFromDate_CompareToDate bigint,@Total_Reach_Percentage bigint

		SET @Total_Reach_BaseDate_ToDate = (SELECT sum(profile_followerscount) from #Temp_BaseDate_ToDate)
		SET @Total_Reach_CompareFromDate_CompareToDate = (SELECT sum(profile_followerscount) from #Temp_CompareFromDate_CompareToDate)
		SET @Total_Reach_FromDate_ToDate = (SELECT sum(profile_followerscount) from #Temp_FromDate_ToDate)
		SET @Total_Reach_Percentage =isnull( (SELECT round( ((convert(decimal(18,2),@Total_Reach_FromDate_ToDate-@Total_Reach_CompareFromDate_CompareToDate))*100/convert(decimal(18,2),nullif(@Total_Reach_CompareFromDate_CompareToDate,0))),0)),0)

		--Total Threads - 59 / 100 -13%
		DECLARE @Total_Threads_BaseDate_ToDate bigint,@Total_Threads_FromDate_ToDate bigint,@Total_Threads_CompareFromDate_CompareToDate bigint,@Total_Threads_Percentage bigint

		SET @Total_Threads_BaseDate_ToDate = (SELECT count(distinct tweet_conversationid) from #Temp_BaseDate_ToDate)
		SET @Total_Threads_CompareFromDate_CompareToDate = (SELECT count(distinct tweet_conversationid) from #Temp_CompareFromDate_CompareToDate)
		SET @Total_Threads_FromDate_ToDate = (SELECT count(tweet_conversationid) from #Temp_FromDate_ToDate)
		SET @Total_Threads_Percentage =isnull( (SELECT round( ((convert(decimal(18,2),@Total_Threads_FromDate_ToDate-@Total_Threads_CompareFromDate_CompareToDate))*100/convert(decimal(18,2),nullif(@Total_Threads_CompareFromDate_CompareToDate,0))),0)),0)

		--Total Engagement - 549 / 700 -13%
		DECLARE @Total_Engagement_BaseDate_ToDate bigint,@Total_Engagement_FromDate_ToDate bigint,@Total_Engagement_CompareFromDate_CompareToDate bigint,@Total_Engagement_Percentage bigint

		SET @Total_Engagement_BaseDate_ToDate = (SELECT sum(engagement_total) from #Temp_BaseDate_ToDate)
		SET @Total_Engagement_CompareFromDate_CompareToDate = (SELECT sum(engagement_total) from #Temp_CompareFromDate_CompareToDate)
		SET @Total_Engagement_FromDate_ToDate = (SELECT sum(engagement_total) from #Temp_FromDate_ToDate)
		SET @Total_Engagement_Percentage =isnull( (SELECT round( ((convert(decimal(18,2),@Total_Engagement_FromDate_ToDate-@Total_Engagement_CompareFromDate_CompareToDate))*100/convert(decimal(18,2),nullif(@Total_Engagement_CompareFromDate_CompareToDate,0))),0)),0)

		--Total Views - 173 / 400 -13%
		DECLARE @Total_Views_BaseDate_ToDate bigint,@Total_Views_FromDate_ToDate bigint,@Total_Views_CompareFromDate_CompareToDate bigint,@Total_Views_Percentage bigint

		SET @Total_Views_BaseDate_ToDate = (SELECT sum(engagement_viewcount) from #Temp_BaseDate_ToDate)
		SET @Total_Views_CompareFromDate_CompareToDate = (SELECT sum(engagement_viewcount) from #Temp_CompareFromDate_CompareToDate)
		SET @Total_Views_FromDate_ToDate = (SELECT sum(engagement_viewcount) from #Temp_FromDate_ToDate)
		SET @Total_Views_Percentage =isnull( (SELECT round( ((convert(decimal(18,2),@Total_Views_FromDate_ToDate-@Total_Views_CompareFromDate_CompareToDate))*100/convert(decimal(18,2),nullif(@Total_Views_CompareFromDate_CompareToDate,0))),0)),0)

		--Total Participants - 173 / 400 -13%
		DECLARE @Total_Participants_BaseDate_ToDate bigint,@Total_Participants_FromDate_ToDate bigint,@Total_Participants_CompareFromDate_CompareToDate bigint,@Total_Participants_Percentage bigint

		SET @Total_Participants_BaseDate_ToDate = (SELECT count(distinct THID) from #Temp_BaseDate_ToDate)
		SET @Total_Participants_CompareFromDate_CompareToDate = (SELECT count(distinct THID) from #Temp_CompareFromDate_CompareToDate)
		SET @Total_Participants_FromDate_ToDate = (SELECT count(distinct THID) from #Temp_FromDate_ToDate)
		SET @Total_Participants_Percentage =isnull( (SELECT round( ((convert(decimal(18,2),@Total_Participants_FromDate_ToDate-@Total_Participants_CompareFromDate_CompareToDate))*100/convert(decimal(18,2),nullif(@Total_Participants_CompareFromDate_CompareToDate,0))),0)),0)

		--Total MI_Participants - 173 / 400 -13%
		DECLARE @Total_MIParticipants_BaseDate_ToDate bigint,@Total_MIParticipants_FromDate_ToDate bigint,@Total_MIParticipants_CompareFromDate_CompareToDate bigint,@Total_MIParticipants_Percentage bigint

		SET @Total_MIParticipants_BaseDate_ToDate = (SELECT count(distinct THID) from #Temp_BaseDate_ToDate WHERE (UserProfileCategory like '%Journalist%') OR (UserProfileCategory like '%Reporter%') OR (UserProfileCategory like '%Influencer%'))
		SET @Total_MIParticipants_CompareFromDate_CompareToDate = (SELECT count(distinct THID) from #Temp_CompareFromDate_CompareToDate WHERE (UserProfileCategory like '%Journalist%') OR (UserProfileCategory like '%Reporter%') OR (UserProfileCategory like '%Influencer%'))
		SET @Total_MIParticipants_FromDate_ToDate = (SELECT count(distinct THID) from #Temp_FromDate_ToDate WHERE (UserProfileCategory like '%Journalist%') OR (UserProfileCategory like '%Reporter%') OR (UserProfileCategory like '%Influencer%'))
		SET @Total_MIParticipants_Percentage =isnull( (SELECT round( ((convert(decimal(18,2),@Total_MIParticipants_FromDate_ToDate-@Total_MIParticipants_CompareFromDate_CompareToDate))*100/convert(decimal(18,2),nullif(@Total_MIParticipants_CompareFromDate_CompareToDate,0))),0)),0)


		----Total New_Participants - 173 / 400 -13%
		DECLARE @New_Participants bigint
		SET @New_Participants = (SELECT count(distinct THID) from #Temp_FromDate_ToDate WHERE THID not in (SELECT THID from #Temp_BaseDate_FromDate))
		
		----Total Active_Participants - 173 / 400 -13%
		DECLARE @Active_Participants bigint
		SET @Active_Participants = --(SELECT count(distinct profile_handle) from #Temp_BaseDate_FromDate)
		(SELECT count(distinct THID) from #Temp_FromDate_ToDate WHERE THID in (SELECT THID from #Temp_BaseDate_FromDate))
		
		

		--Need To Check Start

		SELECT TCID,Tweet_Date into #Temp_BaseDate_ToDate_CT 
		FROM [dbo].TagLinkTweetMapConversation TC with (nolock)
		LEFT JOIN LinkTweet_Detail TD with (nolock) ON TC.Tweet_ConversationID=TD.UpdatedConversationID
		INNER JOIN LinkTweet T with (nolock) ON T.LTID=TD.LTID
		INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
		INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
		WHERE e.EventID=@TopicID AND TC.Is_Detail_Fetched = 1 AND IsRelevant=1 AND NeedToParseTree=1 AND t.Tweet_Date >= @BaseDate AND t.Tweet_Date <= @ToDate

		CREATE NONCLUSTERED INDEX ix_Temp_BaseDate_ToDate_CT ON #Temp_BaseDate_ToDate_CT (Tweet_Date)

		SELECT TCID,Tweet_Date into #Temp_BaseDate_FromDate_CT FROM #Temp_BaseDate_ToDate_CT
		WHERE Tweet_Date >= @BaseDate AND Tweet_Date <= @FromDate

		CREATE NONCLUSTERED INDEX ix_Temp_BaseDate_FromDate_CT ON #Temp_BaseDate_FromDate_CT (Tweet_Date)

		SELECT TCID,Tweet_Date into #Temp_FromDate_ToDate_CT FROM #Temp_BaseDate_ToDate_CT
		WHERE Tweet_Date >= @FromDate AND Tweet_Date <= @ToDate

		CREATE NONCLUSTERED INDEX ix_Temp_FromDate_ToDate_CT ON #Temp_FromDate_ToDate_CT (Tweet_Date)

		--SELECT 1 as Number into #Temp_BaseDate_ToDate_CT
		--SELECT 1 as Number into #Temp_BaseDate_FromDate_CT
		--SELECT 1 as Number into #Temp_FromDate_ToDate_CT


		----Total New_Threads - 173 / 400 -13%
		DECLARE @New_Threads bigint
		SET @New_Threads = (SELECT count(distinct TCID) from #Temp_FromDate_ToDate_CT WHERE TCID not in (SELECT TCID from #Temp_BaseDate_FromDate_CT))
		
		----Total Active_Threads - 173 / 400 -13%
		DECLARE @Active_Threads bigint
		SET @Active_Threads =(SELECT count(distinct TCID) from #Temp_FromDate_ToDate_CT WHERE TCID in (SELECT TCID from #Temp_BaseDate_FromDate_CT))

		SET @Total_Threads_FromDate_ToDate = @New_Threads + @Active_Threads
		------------------------------------------------------------

		--Total RT - 173 / 400 -13%
		DECLARE @Total_RT_BaseDate_ToDate bigint,@Total_RT_FromDate_ToDate bigint,@Total_RT_CompareFromDate_CompareToDate bigint,@Total_RT_Percentage bigint

		select t.tweet_date,t.Tweet_ID as Tweet_ID
		into #RT
		FROM [dbo].LinkTweet t with (nolock)
		inner join LinkTweet_Detail ld with (nolock) on ld.LTID = t.LTID
		inner join TwitterHandle th with (nolock) on th.THID = t.THID
		inner join LinkTweet_Engagement LTE with (nolock) on LTE.LTID = t.LTID
		INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
		INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
		WHERE e.EventID=@TopicID AND t.Tweet_Date >= @BaseDate AND t.Tweet_Date <= @ToDate 
		and ld.Tweet_RetweetedToTweetID in (select distinct Tweet_ID from #Temp_BaseDate_ToDate) 


		CREATE NONCLUSTERED INDEX ix_RT ON #RT (tweet_date)

		SET @Total_RT_BaseDate_ToDate = (SELECT count(distinct Tweet_ID) from #RT)
		SET @Total_RT_CompareFromDate_CompareToDate = (SELECT count(distinct Tweet_ID) from #RT where Tweet_Date>=@CompareFromDate AND Tweet_Date<=@CompareToDate)
		SET @Total_RT_FromDate_ToDate = (SELECT count(distinct Tweet_ID) from #RT where Tweet_Date>=@FromDate AND Tweet_Date<=@ToDate)
		SET @Total_RT_Percentage = isnull( (SELECT round( ((convert(decimal(18,2),@Total_RT_FromDate_ToDate-@Total_RT_CompareFromDate_CompareToDate))*100/convert(decimal(18,2),nullif(@Total_RT_CompareFromDate_CompareToDate,0))),0)),0)

		drop table #RT

		------------------------------------------------------------

		--Create Stats Start
		SELECT  'compare' as card_type,'Total Tweets' as title,convert(varchar,dbo.GetFormat(@Total_Tweets_FromDate_ToDate)) as current_value,
		convert(varchar,dbo.GetFormat(@Total_Tweets_BaseDate_ToDate)) as total_value,replace(convert(varchar,@Total_Tweets_Percentage),'-','') as percentage_change,
		case when @Total_Tweets_Percentage>0 then '+' when @Total_Tweets_Percentage<0 then '-' when @Total_Tweets_Percentage=0 then '' end as percentage_state
		,'true' as navigation

		UNION ALL

		SELECT  'compare' as card_type,'Total Reach' as title,dbo.GetFormat(@Total_Reach_FromDate_ToDate) as current_value,
		dbo.GetFormat(@Total_Reach_BaseDate_ToDate) as total_value,replace(convert(varchar,@Total_Reach_Percentage),'-','') as percentage_change,
		case when @Total_Reach_Percentage>0 then '+' when @Total_Reach_Percentage<0 then '-' when @Total_Reach_Percentage=0 then '' end as percentage_state
		,'true' as navigation

		UNION ALL

		SELECT  'compare' as card_type,'Total Views' as title,convert(varchar,dbo.GetFormat(@Total_Views_FromDate_ToDate)) as current_value,
		dbo.GetFormat(convert(varchar,@Total_Views_BaseDate_ToDate)) as total_value,replace(convert(varchar,@Total_Views_Percentage),'-','') as percentage_change,
		case when @Total_Views_Percentage>0 then '+' when @Total_Views_Percentage<0 then '-' when @Total_Views_Percentage=0 then '' end as percentage_state
		,'true' as navigation

		UNION ALL

		SELECT  'compare' as card_type,'Total Engagement' as title,convert(varchar,dbo.GetFormat(isnull(@Total_Engagement_FromDate_ToDate,0))) as current_value,
		dbo.GetFormat(convert(varchar,@Total_Engagement_BaseDate_ToDate)) as total_value,replace(convert(varchar,@Total_Engagement_Percentage),'-','') as percentage_change,
		case when @Total_Engagement_Percentage>0 then '+' when @Total_Engagement_Percentage<0 then '-' when @Total_Engagement_Percentage=0 then '' end as percentage_state
		,'true' as navigation

		UNION ALL

		SELECT  'compare' as card_type,'Media & Influencers' as title,convert(varchar,@Total_MIParticipants_FromDate_ToDate) as current_value,
		convert(varchar,@Total_MIParticipants_BaseDate_ToDate) as total_value,replace(convert(varchar,@Total_MIParticipants_Percentage),'-','') as percentage_change,
		case when @Total_MIParticipants_Percentage>0 then '+' when @Total_MIParticipants_Percentage<0 then '-' when @Total_MIParticipants_Percentage=0 then '' end as percentage_state
		,'true' as navigation

		UNION ALL

		SELECT  'compare' as card_type,'Total Participants' as title,convert(varchar,dbo.GetFormat(@Total_Participants_FromDate_ToDate)) as current_value,
		dbo.GetFormat((convert(varchar,@Total_Participants_BaseDate_ToDate))) as total_value,replace(convert(varchar,@Total_Participants_Percentage),'-','') as percentage_change,
		case when @Total_Participants_Percentage>0 then '+' when @Total_Participants_Percentage<0 then '-' when @Total_Participants_Percentage=0 then '' end as percentage_state
		,'true' as navigation

		UNION ALL

		--SELECT  'compare' as card_type,'Total Threads' as title,convert(varchar,dbo.GetFormat(@Total_Threads_FromDate_ToDate)) as current_value,
		--dbo.GetFormat(convert(varchar,@Total_Threads_BaseDate_ToDate)) as total_value,replace(convert(varchar,@Total_Threads_Percentage),'-','') as percentage_change,
		--case when @Total_Threads_Percentage>0 then '+' when @Total_Threads_Percentage<0 then '-' when @Total_Threads_Percentage=0 then '' end as percentage_state
		--,'false' as navigation

		SELECT  'compare' as card_type,'Total Threads' as title,convert(varchar,dbo.GetFormat(@Total_Threads_FromDate_ToDate)) as current_value,
		'' as total_value,'0' as percentage_change,
		'' as percentage_state
		,'false' as navigation

		UNION ALL

		SELECT  'compare' as card_type,'New Participants' as title,convert(varchar,dbo.GetFormat(@New_Participants)) as current_value,
		'' as total_value,'0' as percentage_change,'' as percentage_state
		--convert(varchar,@Total_New_Participants_BaseDate_ToDate) as total_value,replace(convert(varchar,@Total_New_Participants_Percentage),'-','') as percentage_change,
		--case when @Total_New_Participants_Percentage>0 then '+' when @Total_New_Participants_Percentage<0 then '-' when @Total_New_Participants_Percentage=0 then '' end as percentage_state
		,'true' as navigation

		UNION ALL

		SELECT  'compare' as card_type,'New Threads' as title,convert(varchar,@New_Threads) as current_value,
		'' as total_value,'0' as percentage_change,'' as percentage_state
		--convert(varchar,@Total_New_Participants_BaseDate_ToDate) as total_value,replace(convert(varchar,@Total_New_Participants_Percentage),'-','') as percentage_change,
		--case when @Total_New_Participants_Percentage>0 then '+' when @Total_New_Participants_Percentage<0 then '-' when @Total_New_Participants_Percentage=0 then '' end as percentage_state
		,'false' as navigation

		UNION ALL

		SELECT  'compare' as card_type,'Active Participants' as title,convert(varchar,@Active_Participants) as current_value,
		'' as total_value,'0' as percentage_change,'' as percentage_state
		--convert(varchar,@Total_New_Participants_BaseDate_ToDate) as total_value,replace(convert(varchar,@Total_New_Participants_Percentage),'-','') as percentage_change,
		--case when @Total_New_Participants_Percentage>0 then '+' when @Total_New_Participants_Percentage<0 then '-' when @Total_New_Participants_Percentage=0 then '' end as percentage_state
		,'true' as navigation

		UNION ALL

		SELECT  'compare' as card_type,'Active Threads' as title,convert(varchar,@Active_Threads) as current_value,
		'' as total_value,'0' as percentage_change,'' as percentage_state
		--convert(varchar,@Total_New_Participants_BaseDate_ToDate) as total_value,replace(convert(varchar,@Total_New_Participants_Percentage),'-','') as percentage_change,
		--case when @Total_New_Participants_Percentage>0 then '+' when @Total_New_Participants_Percentage<0 then '-' when @Total_New_Participants_Percentage=0 then '' end as percentage_state
		,'false' as navigation

		UNION ALL

		SELECT  'compare' as card_type,'Total Retweets' as title,convert(varchar,dbo.GetFormat(@Total_RT_FromDate_ToDate)) as current_value,
		dbo.GetFormat(convert(varchar,@Total_RT_BaseDate_ToDate)) as total_value,replace(convert(varchar,@Total_RT_Percentage),'-','') as percentage_change,
		case when @Total_RT_Percentage>0 then '+' when @Total_RT_Percentage<0 then '-' when @Total_RT_Percentage=0 then '' end as percentage_state
		,'false' as navigation
		

		--Create Stats End
		--------------------------------------------------------------------------------------------------------------------------------------------

		--twitter_stats END




		----------------------------------------------------------------------------------------------------------------------------------------------------------
		

		--select 1 as a
		--select 2 as b
		--select 3 as c
		----------------------------------------------------------------------------------------------------------------------------------------------------------
		--DROP TABLES START
		DROP TABLE #Temp_BaseDate_ToDate,#Temp_BaseDate_FromDate ,#Temp_FromDate_ToDate,#Temp_CompareFromDate_CompareToDate,#Temp_BaseDate_ToDate_CT,#Temp_BaseDate_FromDate_CT ,#Temp_FromDate_ToDate_CT
		--DROP TABLES END
END