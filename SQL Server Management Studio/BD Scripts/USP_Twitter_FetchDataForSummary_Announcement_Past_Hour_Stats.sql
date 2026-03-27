
--EXEC [dbo].[USP_Twitter_FetchDataForSummary_Announcement_Past_Hour_Stats] 3,'2024-11-15 00:00:00','2025-01-02 16:43:00','2025-01-03 09:56:26'
ALTER PROC [dbo].[USP_Twitter_FetchDataForSummary_Announcement_Past_Hour_Stats]
@TopicID INT=0, 
@BaseDate Datetime= NULL, 
@FromDate Datetime= NULL, 
@ToDate Datetime= NULL, 
@Type VARCHAR(100)= NULL
AS 
BEGIN


DECLARE @EntityID INT, @IssueDescription NVARCHAR(MAX)

SELECT TOP 1 @EntityID=ClientID, @IssueDescription=Description FROM [dbo].[Event] WITH (NOLOCK) WHERE EventID=@TOPicID

SELECT DISTINCT  t.*,C.Name [EntityName],C.Description [EntityDescription],LE.Summary [AE_Summary]
,LED.Sentiment,E.EventName,E.Description [TOPicDescription]
,t.Tweet_Text [Headline],th.profile_followerscount,LTE.engagement_viewcount,LTE.engagement_likecount,ld.Tweet_IsRetweeted
,LTE.Engagement_RetweetCount,th.Profile_Category,th.Profile_Handle,ld.Tweet_ConversationID
INTO #Temp_Twitter_Begining  
FROM [dbo].LinkTweet t with (nolock)
			inner join LinkTweet_Detail ld with (nolock) on ld.LTID = t.LTID
			inner join TwitterHandle th with (nolock) on th.THID = t.THID
			inner join LinkTweet_Engagement LTE with (nolock) on LTE.LTID = t.LTID
			INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
			INNER JOIN [dbo].[LinkTweet_Enriched] LE with (nolock) ON LE.LTID = t.LTID
			INNER JOIN [dbo].[LinkTweet_EnrichedDetail] LED with (nolock) ON LED.TLTMEID = TLOME.TLTMEID
			INNER JOIN [dbo].mstTonality_Enriched ME with (nolock) ON ME.TonalityID = LED.TonalityID
			INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
			INNER JOIN [dbo].[Client] C WITH (NOLOCK) ON C.ClientID=E.ClientID
			LEFT JOIN Bookmark B WITH (NOLOCK) on tlom.TLTMID= B.RecordID and PlatformID=3
			WHERE e.EventID=3 
			AND t.Tweet_Date >= @BaseDate AND t.Tweet_Date <= @ToDate 
			AND ld.Tweet_IsRetweeted = 0 AND led.Is_Relevant_About_Topic=1

SELECT DISTINCT *
INTO #Temp_Twitter  
FROM #Temp_Twitter_Begining
WHERE Tweet_Date BETWEEN FORMAT(CONVERT(datetime, @FromDate, 100), 'yyyy-MM-dd HH:mm:ss')   
AND FORMAT(CONVERT(datetime, @ToDate, 100), 'yyyy-MM-dd HH:mm:ss')


DECLARE @CompareFromDate_FB smalldatetime,@CompareFromDate_STW smalldatetime,@total_velocity_FB int=0,@total_velocity_STW int=0,@total_volume_FB int=0,@total_volume_STW int=0

SELECT @total_volume_FB= (SELECT Count(*) FROM #Temp_Twitter_Begining A WITH(NOLOCK))
SELECT @total_volume_STW= (SELECT Count(*) FROM #Temp_Twitter A WITH(NOLOCK))

SET @CompareFromDate_FB = (SELECT DATEADD(MINUTE, -DATEDIFF(MINUTE, @BaseDate, @ToDate), @BaseDate))
SET @CompareFromDate_STW = (SELECT DATEADD(MINUTE, -DATEDIFF(MINUTE, @FromDate, @ToDate), @FromDate))

--select @total_volume_FB,@total_volume_STW
--select DATEDIFF(MINUTE, @CompareFromDate_FB, @FromDate)
--select  DATEDIFF(MINUTE, @CompareFromDate_STW, @FromDate)

SET @total_velocity_FB = (select @total_volume_FB / DATEDIFF(MINUTE, @CompareFromDate_FB, @FromDate))
SET @total_velocity_STW = (select @total_volume_STW / DATEDIFF(MINUTE, @CompareFromDate_STW, @FromDate))

IF(@Type='Enriched_Data')
BEGIN

	SELECT DISTINCT  LED.*
	FROM [dbo].LinkTweet t with (nolock)
	inner join LinkTweet_Detail ld with (nolock) on ld.LTID = t.LTID
	inner join TwitterHandle th with (nolock) on th.THID = t.THID
	inner join LinkTweet_Engagement LTE with (nolock) on LTE.LTID = t.LTID
	INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
	INNER JOIN [dbo].[LinkTweet_Enriched] LE with (nolock) ON LE.LTID = t.LTID
	INNER JOIN [dbo].[LinkTweet_EnrichedDetail] LED with (nolock) ON LED.TLTMEID = TLOME.TLTMEID
	INNER JOIN [dbo].mstTonality_Enriched ME with (nolock) ON ME.TonalityID = LED.TonalityID
	INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
	INNER JOIN [dbo].[Client] C WITH (NOLOCK) ON C.ClientID=E.ClientID
	LEFT JOIN Bookmark B WITH (NOLOCK) on tlom.TLTMID= B.RecordID and PlatformID=3
	WHERE e.EventID=3 
	AND t.Tweet_Date >= @FromDate AND t.Tweet_Date <= @ToDate 
	AND ld.Tweet_IsRetweeted = 0 AND led.Is_Relevant_About_Topic=1

END
ELSE
BEGIN

	SELECT DISTINCT TOP 1 
	[EntityName] as Name_of_the_client
	,EventName AS Announcement_Event
	,[EntityDescription] as EntityDescription
	,[TOPicDescription] as IssueDescription
	,(SELECT Count(*) FROM #Temp_Twitter_Begining A WITH(NOLOCK)) AS Total_no_of_Tweets_FB --From the beginig
	,@total_velocity_FB as  velocity_FB
	,(SELECT Count(*) FROM #Temp_Twitter A WITH(NOLOCK)) AS Total_no_of_Tweets_STW --Specific time window
	,@total_velocity_STW as  velocity_STW

	,(SELECT Count(*) FROM #Temp_Twitter_Begining A WITH(NOLOCK)) AS Total_no_of_tweets_around_the_Issue
	,(SELECT Count(*) FROM #Temp_Twitter A WITH(NOLOCK)) AS No_of_tweets_in_the_specfic_time_period
	,(SELECT sum(profile_followerscount) as TotalReach from #Temp_Twitter) AS Total_Reach
	,(SELECT sum(engagement_viewcount) as Total_Views from #Temp_Twitter) AS Total_Views
	,(SELECT sum(engagement_likecount) as Total_Views from #Temp_Twitter) AS Total_Likes
	,(SELECT TOP 1 Sentiment
		    FROM (SELECT TOP 1 Count( Sentiment) AS 'Volume' ,Sentiment FROM #Temp_Twitter_Begining AO WITH(NOLOCK)  
			Group by Sentiment
			order by Count( Sentiment) DESC
		    ) AS Overall_sentiment_of_previous_timeline
		) AS Overall_sentiment_of_previous_timeline_FB
	,(SELECT TOP 1 Sentiment
		    FROM (SELECT TOP 1 Count( Sentiment) AS 'Volume' ,Sentiment FROM #Temp_Twitter AO WITH(NOLOCK)  
			Group by Sentiment
			order by Count( Sentiment) DESC
		    ) AS Overall_sentiment_of_previous_timeline
		) AS Overall_sentiment_of_previous_timeline_STW
	,(select TOP 1 tweet_text from #Temp_Twitter order by Engagement_RetweetCount desc) as tweet_of_the_handle_which_received_the_highest_retweet
	,(SELECT TOP 1 tweet_text  from #Temp_Twitter order by profile_followerscount desc) AS tweet_of_the_top_influencers
	,(select top 1 COunt(Profile_Handle) from(
	SELECT  Profile_Handle  from #Temp_Twitter where Profile_Category='Media Channels' group by Profile_Handle) as Profile_Handle) AS No_of_media_handle_who_tweeted_about_the_client
	,(SELECT STUFF((
		    SELECT ',@'  + ISNUll(Profile_Handle,'')+';'
		    FROM (
		        SELECT TOP 3 Profile_Handle,profile_followerscount
				FROM #Temp_Twitter A WITH(NOLOCK)
				WHERE Profile_Category='Media Channels' and Profile_Handle IS NOT NULL
				group by Profile_Handle,profile_followerscount
				order by profile_followerscount desc
		    ) AS AggregatedData
		    FOR XML PATH('')), 1, 1, '') AS TopAuthors) AS Top_media_handle_who_tweeted_about_the_client
	,(select TOP 1 '@'+ Profile_Handle from #Temp_Twitter order by Engagement_RetweetCount desc) as Individual_with_the_most_retweets
	,(SELECT STUFF((
		    SELECT ',' + ISNUll(Profile_Handle,'') +',' + ISNUll(CONVERT(VARCHAR(100),Engagement_RetweetCount),'')+';'
		    FROM (
		        SELECT distinct TOP 3 Engagement_RetweetCount,Profile_Handle 
				FROM #Temp_Twitter A WITH(NOLOCK)  				
				order by Engagement_RetweetCount desc
		    ) AS AggregatedData
		    FOR XML PATH('')), 1, 1, '') AS Engagement_RetweetCount) AS Profile_and_No_of_retweets_the_Individual_with_most_retweets_received

	--,'' as Conversation_theme_of_the_individual_with_the_most_retweets
	,(SELECT STUFF((
		    SELECT ',' + ISNUll(Profile_Handle,'') +',' + ISNUll(CONVERT(VARCHAR(100),Profile_Category),'')+';'
		    FROM (
		        SELECT  TOP 3 Profile_Category,Profile_Handle,profile_followerscount
				FROM #Temp_Twitter A WITH(NOLOCK)  				
				group by Profile_Category,Profile_Handle,profile_followerscount
				order by profile_followerscount desc
		    ) AS AggregatedData
		    FOR XML PATH('')), 1, 1, '') AS Profile_Category) AS Top_influencer_and_type_of_influencer_who_talked_about_the_client

	--,'' as Topic_the_influencers_talked_about_the_client
	,(SELECT STUFF((
		    SELECT ',' + ISNUll(CONVERT(VARCHAR(100),engagement_viewcount),'') +',' + ISNUll(CONVERT(VARCHAR(100),Engagement_RetweetCount),'')+';'
		    FROM (
		        select top 1 engagement_viewcount,Engagement_RetweetCount,profile_handle from #Temp_Twitter 
			group by engagement_viewcount,Engagement_RetweetCount,profile_handle
			order by engagement_viewcount desc
		    ) AS AggregatedData
		    FOR XML PATH('')), 1, 1, '') AS Total_Views_and_retweets_of_the_influencer) AS  Total_Views_and_retweets_of_the_influencer
	,(SELECT STUFF((
		    SELECT ',' + ISNUll(Profile_Handle,'') +',' + ISNUll(CONVERT(VARCHAR(100),profile_followerscount),'')+';'
		    FROM (
		        SELECT top 3 Profile_Handle,profile_followerscount,Count(Profile_Handle) as Tweet_Count
				FROM #Temp_Twitter A WITH(NOLOCK)  				
				group by Profile_Handle,profile_followerscount
				order by Tweet_Count desc
		    ) AS AggregatedData
		    FOR XML PATH('')), 1, 1, '') AS Profile_Category) AS Individual_who_had_tweeted_more_about_the_issue_and_no_of_followers

	,(SELECT STUFF((
		    SELECT  ISNUll(CONVERT(VARCHAR(100),Tweet_Count),'')
		    FROM (
		        SELECT top 1 Profile_Handle,Count(Profile_Handle) as Tweet_Count
				FROM #Temp_Twitter A WITH(NOLOCK)  				
				group by Profile_Handle
				order by Tweet_Count desc
		    ) AS AggregatedData
		    FOR XML PATH('')), 1,0, '') AS Profile_Category) AS No_of_tweets_Individual_who_had_tweeted_more_about_the_issue_in_the_selected_time_period
	,(SELECT STUFF((
		    SELECT  ISNUll(CONVERT(VARCHAR(100),Tweet_Count),'')
		    FROM (
		        SELECT top 1 Profile_Handle,Count(Profile_Handle) as Tweet_Count
				FROM #Temp_Twitter_Begining A WITH(NOLOCK) 
				where Profile_Handle = (SELECT top 1 Profile_Handle
				FROM #Temp_Twitter A WITH(NOLOCK)  				
				group by Profile_Handle
				order by Count(Profile_Handle) desc)
				group by Profile_Handle
		    ) AS AggregatedData
		    FOR XML PATH('')), 1,0, '') AS Profile_Category) AS Total_no_of_tweets_the_Individual_who_had_tweeted_more_about_the_issue

	
	,'' as Tweet_Thread
	,(SELECT TOP 1 tweetcount
		    FROM (select top 1 Tweet_ConversationID,count(*) as tweetcount from #Temp_Twitter 
			group by Tweet_ConversationID
			order by tweetcount desc
		    ) AS tweetcount
		) AS No_of_tweets_in_a_thread_which_has_maximum_number_of_tweets


	
	FROM #Temp_Twitter	

	
END

END