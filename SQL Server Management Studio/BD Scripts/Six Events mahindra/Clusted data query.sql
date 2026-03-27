

--select COUNT(1) from #Shiv_Mahindra
--select * from #Shiv_Mahindra

select count( distinct url) from #Shiv_Mahindra

--drop table #Shiv_Mahindra

select 


select distinct tlom.TLOMID as article_id,e.EventID as incident_id,AO.Url as url,
			    CASE 
        WHEN LOWER(ISNULL(LP.text,Ao.text)) LIKE '%truck%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%bus%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%buses%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%tractor%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%cvs%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%commercial vehicle%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%commercial evs%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%lcv%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%cargo%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%construction%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%3-wheeler%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%bolero%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%veero%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%mahindra blazo%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%maxx pik up%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%agriculture%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%farm%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%auto-comp%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%auto components%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%last mile mobility%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%rickshaw%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%e-rickshaw%' 
        THEN 'Yes'
        ELSE 'No'
    END AS Is_Not_PV,

    CASE 
        WHEN LOWER(ISNULL(LP.text,Ao.text)) LIKE '%tech mahindra%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%mahindra lifespaces%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%kotak mahindra%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%kotak amc%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%mahindra logistics%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%mahindra finance%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%mahindra armado%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%activa%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%jawa 350%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%hero electra%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%bajaj%' 
          OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%tvs%' 
        THEN 'Yes'
        ELSE 'No'
    END AS Is_Not_Relevant_Company
	,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%XUV700%'  then 'Yes' ELSE 'No' end as 'XUV700'
	,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%Scorpio-N%'  then 'Yes' ELSE 'No' end as 'Scorpio-N'
	,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%Thar ROXX%'  then 'Yes' ELSE 'No' end as 'Thar_ROXX'
	,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%XUV 3XO%'  then 'Yes' ELSE 'No' end as 'XUV_3XO'
	,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%BE 6%'  then 'Yes' ELSE 'No' end as 'BE_6'
	,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%XEV 9e%'  then 'Yes' ELSE 'No' end as 'XEV_9e'
	into #Shiv_Mahindra
			
			FROM dbo.LinkOnline AO with (nolock)
			INNER JOIN [dbo].[LinkOnline_Processed] LP WITH (NOLOCK) ON LP.LOPID=AO.LOPID
			LEFT JOIN [dbo].mstLinkOnlineAuthor MLOA WITH (NOLOCK) ON MLOA.AuthorID=AO.AuthorID
			INNER JOIN [dbo].mstPublication P WITH (NOLOCK) ON p.PublicationID = AO.PublicationID
			INNER JOIN [dbo].[TagLinkOnlineMap] tlom WITH (NOLOCK) ON tlom.LOID=AO.LOID INNER JOIN [dbo].[TagLinkOnlineMapE] TLOME with(nolock) on TLOME.TLOMID=tlom.TLOMID
			INNER JOIN [dbo].[LinkOnline_Enriched] LE with (nolock) ON LE.LOID = AO.LOID
			INNER JOIN [dbo].[LinkOnline_EnrichedDetail] LED with (nolock) ON LED.TLOMEID = TLOME.TLOMEID
			INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
			LEFT JOIN [dbo].[Bookmark] B WITH (NOLOCK) on tlom.TLOMID= B.RecordID and PlatformID=1 AND (634 = 0 OR B.UserID =634)
			LEFT JOIN mstLanguage lan  with (nolock) ON lan.LanguageID = LE.LanguageID
			OUTER APPLY(select MAX(Category) as Category 	FROM [dbo].[LinkOnline_Enriched_DiscourseCategory] LOEDC WITH (NOLOCK)
					INNER JOIN [dbo].[mstArticleDiscourseCategory_Enriched] MADCE WITH (NOLOCK) ON LE.LOEID = LOEDC.LOEID and MADCE.DiscourseCategoryID = LOEDC.DiscourseCategoryID
					GROUP BY LOEDC.LOEID) as DisCat
			OUTER APPLY(select MAX(ArticleType) as ArticleType 	FROM LinkOnline_Enriched_ArticleType LOEAT  WITH (NOLOCK)
					INNER JOIN mstArticleType_Enriched MATE  WITH (NOLOCK) ON LE.LOEID = LOEAT.LOEID and LOEAT.ArticleTypeID = MATE.ArticleTypeID
					GROUP BY LOEAT.LOEID) as tblArticleType
			WHERE e.EventID=154 AND LP.Date >= '2024-04-01 00:00:00' AND LP.Date <= '2025-04-16 23:00:00' 
			AND (
					(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
				)

select count( distinct url) from #Shiv_Mahindra where url 
not in (
)