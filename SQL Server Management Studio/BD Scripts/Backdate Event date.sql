

--A

select * from client where name like '%Eli Lilly & Company India%'
select * from tag where tagname like '%Competitor analysis%'

select * from tag where TagID=16535
select * from TagQuery where TagID=16535

--update tag set IsActive=1 where TagID=16535

select * from clienttopic where RefTopicID= 4055

--update clienttopic set StartDate='2025-11-01 00:00:00',Status=1 where RefTopicID= 4055
--update tagmap set isactive =1 where clienttopicid=5087 and tagid= 16535
--update tagquery set isactive=1, History_Date='2025-11-01 00:00:00' , IsHistoryDataFetched =0 where tagid= 16535 and PlatformID in (1,2)


--c2--

select * from event where Eventname like '%%'
select * from event where EventID=1686

--update event set EndDate='2025-08-14 23:59:00' where EventID=1686