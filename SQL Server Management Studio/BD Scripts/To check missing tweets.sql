select * from LinkTweet with (nolock) where tweet_id='1897466704730710482'
 
select * from Event where eventname like '%pilot%'
 
 
select * from TagLinkTweetMap with (nolock) where ltid=3292673
 
select * from TagLinkTweetMapE with (nolock) where TLTMID=3309806
 
select * from LinkTweet_EnrichedDetail where TLTMEID=3099540
 
EXEC [dbo].[USP_API_SentryV2_Twitter_FetchList] 407,'2025-01-03 00:00:00','2025-03-06 00:00:00','2025-03-07 09:56:26'



