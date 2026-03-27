--select b.eventname,a.*
--INTO #Event_LinkOnline_Summary
--from [dbo].[Event_LinkOnline_Summary] a with(nolock)
--INNER JOIN Event b with(nolock) on a.eventid=b.eventid
--where a.EventID in (154,155,156,157,158,159)
--and createdat >='2025-04-18'
--order by a.eventid

CREATE TABLE #Temp_Peak
(
RN INT,
EventID INT,
FromDate DATETIME,
ToDate DATETIME,
PeakID INT,
Volume INT
)

INSERT INTO #Temp_Peak(RN, a.EventID,a.FromDate,a.ToDate,PeakID)
select ROW_NUMBER() OVER(ORDER BY PeakID) as RN , a.EventID,a.FromDate,a.ToDate,PeakID
from [dbo].[Event_LinkPrint_Summary] a with(nolock)
INNER JOIN Event b with(nolock) on a.eventid=b.eventid and a.peakid>0
where a.EventID in (153,154,155,156,157,158)
and createdat >='2025-08-06'
and SummaryType='Peak_Negative'
order by a.eventid

declare @Count INT

select @Count = (select COUNT(1) from #Temp_Peak)

WHILE(@Count>0)
BEGIN

	DECLARE @Volume INT,@EventID INT,@FromDate Datetime,@ToDate DATETIME,@PeakID INT

	--select @RN = (select RN from #Temp_Peak where RN=@Count )

	select @EventID=EventID,@FromDate=FromDate,@ToDate=ToDate,@PeakID=PeakID from #Temp_Peak where RN=@Count

	CREATE TABLE #Temp_Peak_Count
	(
	interval_count INT
	)

	INSERT INTO #Temp_Peak_Count
	exec [dbo].[USP_API_SentryV2_Event_TimelinePeak_FetchTimeLine_Shubham_16042025_Shiv]  @EventID,@FromDate,@ToDate,'print',@type='Negative'
	
	select @Volume = (select SUM(interval_count) from #Temp_Peak_Count)

	update #Temp_Peak set Volume =@Volume where RN=@Count

	SET @Count=@Count-1

	drop table #Temp_Peak_Count

END

select *from #Temp_Peak

select b.eventname,a.*,c.Volume
from [dbo].[Event_LinkPrint_Summary] a with(nolock)
INNER JOIN Event b with(nolock) on a.eventid=b.eventid
inner join #Temp_Peak c with(nolock) on a.PeakID=c.PeakID
where a.EventID in (153,154,155,156,157,158) and a.peakid>0
and createdat >='2025-08-06'
order by createdat 


--drop table #Temp_Peak
--drop table #Event_LinkOnline_Summary