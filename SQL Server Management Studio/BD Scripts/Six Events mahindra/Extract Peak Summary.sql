select a.eventID,Count(1) from [dbo].[Event_LinkOnline_Summary] a with(nolock)
INNER JOIN Event b with(nolock) on a.eventid=b.eventid
where a.EventID in (154,155,156,157,158,159)
and createdat >='2025-04-18'
group by a.eventID


select b.eventname,a.* from [dbo].[Event_LinkOnline_Summary] a with(nolock)
INNER JOIN Event b with(nolock) on a.eventid=b.eventid
where a.EventID in (154,155,156,157,158,159)
and createdat >='2025-04-18'
order by a.eventid



select b.eventname,a.* from [dbo].[Event_LinkPrint_Summary] a with(nolock)
INNER JOIN Event b with(nolock) on a.eventid=b.eventid
where a.EventID in (154,155,156,157,158,159)
and createdat >='2025-04-18'
order by a.eventid


