


select tlom.TLTMID as [Twitter ID]
,t.Tweet_Date as [Date - Time]
,t.Tweet_URL as [URL]
,t.Tweet_Text as [Tweet]
,LED.Sentiment as [Sentiment]
,tonality as [Tonality]
,engagement_retweetcount as [Retweet]
,engagement_replycount as [Reply]
,engagement_likecount as [Likes]
,profile_followerscount as [Reach]
,(engagement_retweetcount+engagement_replycount+engagement_likecount+engagement_quotecount+engagement_bookmarkcount) as [Engagement]
,engagement_quotecount as [Retweet Quote]
,engagement_viewcount as [Views]
,'' as [Hashtags]
,TypeOfListening as [Mention type]
,'' AS [Mentioned Handles]
,'' as [Mentioned Images]
,'' AS [Mentioned Hyperlinks]
,'' AS [Mentioned Videos]
,'' as [Media Type]
,case when B.BookmarkID is null then 0 else 1 end as [Bookmarked]
,profile_handle as [Profile Handle]
, profile_name as [Profile Name]
--,case 	WHEN profile_handle in ((SELECT profile_handle from #TempNoFilter_BaseToFrom)) THEN 'Active'
--WHEN profile_handle not in ((SELECT profile_handle from #TempNoFilter_BaseToFrom)) THEN 'New'
--END as [Participant Type]
,profile_followerscount as [Followers]
,profile_followingcount as [Following]
,profile_tweetscount as [Total Tweet count]
,profile_isverified as Verified
,profile_verifiedtype as [Profile verified type]
,Profile_Category as [Profile Category]
,Profile_JoinedDate as [Profile Joined Date]
,isnull(Profile_Location,'NA') as [Profile Location]
FROM [dbo].LinkTweet t with (nolock)
inner join LinkTweet_Detail ld with (nolock) on ld.LTID = t.LTID
inner join TwitterHandle th with (nolock) on th.THID = t.THID
inner join LinkTweet_Engagement LTE with (nolock) on LTE.LTID = t.LTID
INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
INNER JOIN [dbo].[LinkTweet_Enriched] LE with (nolock) ON LE.LTID = t.LTID
INNER JOIN [dbo].[LinkTweet_EnrichedDetail] LED with (nolock) ON LED.TLTMEID = TLOME.TLTMEID
INNER JOIN [dbo].mstTonality_Enriched ME with (nolock) ON ME.TonalityID = LED.TonalityID
INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
LEFT JOIN Bookmark B WITH (NOLOCK) on tlom.TLTMID= B.RecordID and PlatformID=3 AND (634 = 0 OR B.UserID =634)
WHERE e.EventID=10 AND t.Tweet_Date >= '2025-01-01 00:00:00'  AND t.Tweet_Date <= '2025-01-02 00:00:00'  
AND ld.Tweet_IsRetweeted = 0 AND led.Is_Relevant_About_Topic=1