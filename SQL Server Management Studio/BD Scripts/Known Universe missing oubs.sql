select * from mstknownuniverse where  in (2,8)
and CreatedAt >='2025-08-01 00:00:00'
group by SourceID



select * from mstknownuniverse 

;WITH CTE AS(
SELECT 
    b.Domain,
    SUM(CASE WHEN a.SourceID = 2 THEN 1 ELSE 0 END) AS [Google],
    SUM(CASE WHEN a.SourceID = 8 THEN 1 ELSE 0 END) AS [Solr]
FROM LinkOnline a WITH (NOLOCK)
INNER JOIN mstknownuniverse b  
    ON a.PublicationID = b.PublicationID
WHERE a.SourceID IN (2, 8)
    AND a.CreatedAt >= '2025-08-01 00:00:00'
GROUP BY b.Domain
)
select * from CTE where [Google]=0 and [Solr]>0




SELECT 
    b.Publication,COUNT(1) as Missing_Articles_Count
FROM LinkOnline a WITH (NOLOCK)
INNER JOIN mstPublication b on a.PublicationID=b.PublicationID 
WHERE a.SourceID IN (8)
    AND a.CreatedAt >= '2025-08-01 00:00:00'
and a.LOID not in (

SELECT 
    a.LOID
FROM LinkOnline a WITH (NOLOCK)
INNER JOIN mstknownuniverse b  
    ON a.PublicationID = b.PublicationID 
WHERE a.SourceID IN (8)
    AND a.CreatedAt >= '2025-08-01 00:00:00'
)
group by b.Publication