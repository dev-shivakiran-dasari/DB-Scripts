--select * into mstPublication_22_04_2025 from mstPublication 


select *from mstPublication a 
INNER JOIN Pub_Shiv_DA b on a.Publication=b.Domain

select *from mstPublication a 
INNER JOIN Pub_Shiv_TotalVisits b on a.Publication=b.Domain

--update a set a.DA=b.DA from mstPublication a 
--INNER JOIN Pub_Shiv_DA b on a.Publication=b.Domain
--update a set a.TotalVisits=b.TotalVisits from mstPublication a 
--INNER JOIN Pub_Shiv_TotalVisits b on a.Publication=b.Domain


select * from Pub_Shiv_DA
select * from Pub_Shiv_TotalVisits





--begin tran
--update b set b.publication_da=a.DA,b.publication_total_visits=a.TotalVisits from mstPublication a 
--INNER JOIN fact_online b on a.Publication=b.publication
--where ModifiedAt='2025-07-21 11:05:00'
----rollback
--commit

--select * from mstPublication where ModifiedAt='2025-07-21 11:05:00'
----update a set a.TotalVisits=b.TotalVisits from mstPublication a 
----INNER JOIN Pub_Shiv_TotalVisits b on a.Publication=b.Domain


--select * from fact_online

--select distinct a.publication,publication_da,DA,publication_total_visits,TotalVisits
--from mstPublication a 
--INNER JOIN fact_online b on a.Publication=b.publication
--where ModifiedAt='2025-07-21 11:05:00'
--order by a.publication desc