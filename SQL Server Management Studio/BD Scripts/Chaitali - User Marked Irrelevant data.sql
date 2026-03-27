select [Name] as ClientName,[EventName],U.CreatedAt,ft.url,'Online' as [Platform] from UserMarkedIrrelevantList U WITH(NOLOCK) 
inner join fact_online ft WITH(NOLOCK) ON ft.event_id=U.RefID and ft.tlom_id=U.RecordID
inner join TagLinkOnlineMap TLOM WITH(NOLOCK) ON  TLOM.TLOMID=U.RecordID
inner join [Event] E WITH(NOLOCK) ON U.RefID=E.EventID
inner join Client c WITH(NOLOCK) ON c.ClientID=E.ClientID
where U.CreatedAt>='2026-03-01 00:00:00.000' and PlatformID=1
UNION ALL
select [Name] as ClientName,[EventName],U.CreatedAt,'http://print.adfactorspr.com/NewsDetailsPublished.aspx?NewsID='+ft.url as URL,'Print' as [Platform]  
from UserMarkedIrrelevantList U WITH(NOLOCK) 
inner join fact_print ft WITH(NOLOCK) ON ft.eventid=U.RefID and ft.tlpmid=U.RecordID
inner join TagLinkPrintMap TLOM WITH(NOLOCK) ON  TLOM.TLPMID=U.RecordID
inner join [Event] E WITH(NOLOCK) ON U.RefID=E.EventID
inner join Client c WITH(NOLOCK) ON c.ClientID=E.ClientID
where U.CreatedAt>='2026-03-01 00:00:00.000' and PlatformID=2
UNION ALL
select [Name] as ClientName,[EventName],U.CreatedAt,t.Tweet_URL as URL,'Twitter' as [Platform]  
from UserMarkedIrrelevantList U WITH(NOLOCK) 
inner join fact_twitter ft WITH(NOLOCK) ON ft.event_id=U.RefID and ft.tltm_id=U.RecordID
inner join LinkTweet t WITH(NOLOCK) ON ft.lt_id=t.LTID
inner join TagLinkTweetMap TLOM WITH(NOLOCK) ON  TLOM.TLTMID=U.RecordID
inner join [Event] E WITH(NOLOCK) ON U.RefID=E.EventID
inner join Client c WITH(NOLOCK) ON c.ClientID=E.ClientID
where U.CreatedAt>='2026-03-01 00:00:00.000' and PlatformID=3
UNION ALL
select [Name] as ClientName,[EventName],U.CreatedAt,ft.video_url as URL,'YouTube' as [Platform]  
from UserMarkedIrrelevantList U WITH(NOLOCK) 
inner join flat_youtube ft WITH(NOLOCK) ON ft.eventid=U.RefID and ft.tlymid=U.RecordID
inner join TagLinkYouTubeMap TLOM WITH(NOLOCK) ON  TLOM.TLYMID=U.RecordID
inner join [Event] E WITH(NOLOCK) ON U.RefID=E.EventID
inner join Client c WITH(NOLOCK) ON c.ClientID=E.ClientID
where U.CreatedAt>='2026-03-01 00:00:00.000' and PlatformID=4
