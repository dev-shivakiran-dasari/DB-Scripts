select distinct tlom.TLOMID as article_id,e.EventID as incident_id
,'Online' as Type
--,AO.Url as url
	--		    ,CASE 
 --       WHEN LOWER(ISNULL(LP.text,Ao.text)) LIKE '%truck%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%bus%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%buses%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%tractor%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%cvs%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%commercial vehicle%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%commercial evs%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%lcv%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%cargo%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%construction%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%3-wheeler%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%bolero%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%veero%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%mahindra blazo%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%maxx pik up%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%agriculture%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%farm%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%auto-comp%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%auto components%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%last mile mobility%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%rickshaw%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%e-rickshaw%' 
 --       THEN 'Yes'
 --       ELSE 'No'
 --   END AS Is_Not_PV,

 --   CASE 
 --       WHEN LOWER(ISNULL(LP.text,Ao.text)) LIKE '%tech mahindra%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%mahindra lifespaces%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%kotak mahindra%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%kotak amc%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%mahindra logistics%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%mahindra finance%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%mahindra armado%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%activa%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%jawa 350%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%hero electra%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%bajaj%' 
 --         OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%tvs%' 
 --       THEN 'Yes'
 --       ELSE 'No'
 --   END AS Is_Not_Relevant_Company
	--,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%XUV700%' OR LOWER(ISNULL(LP.text,Ao.text)) LIKE '%XUV 700%' then 'Yes' ELSE 'No' end as 'XUV700'
	--,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%Scorpio-N%'  then 'Yes' ELSE 'No' end as 'Scorpio-N'
	--,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%Thar ROXX%'  then 'Yes' ELSE 'No' end as 'Thar_ROXX'
	--,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%XUV 3XO%'  then 'Yes' ELSE 'No' end as 'XUV_3XO'
	--,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%BE 6%'  then 'Yes' ELSE 'No' end as 'BE_6'
	--,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%XEV 9e%'  then 'Yes' ELSE 'No' end as 'XEV_9e'
	,case when LOWER(ISNULL(LP.text,Ao.text)) LIKE '%Bolero%'  then 'Yes' ELSE 'No' end as 'Bolero'
	
			
			FROM dbo.LinkOnline AO with (nolock)
			INNER JOIN [dbo].[LinkOnline_Processed] LP WITH (NOLOCK) ON LP.LOPID=AO.LOPID
			LEFT JOIN [dbo].mstLinkOnlineAuthor MLOA WITH (NOLOCK) ON MLOA.AuthorID=AO.AuthorID
			INNER JOIN [dbo].mstPublication P WITH (NOLOCK) ON p.PublicationID = AO.PublicationID
			INNER JOIN [dbo].[TagLinkOnlineMap] tlom WITH (NOLOCK) ON tlom.LOID=AO.LOID INNER JOIN [dbo].[TagLinkOnlineMapE] TLOME with(nolock) on TLOME.TLOMID=tlom.TLOMID
			INNER JOIN [dbo].[LinkOnline_Enriched] LE with (nolock) ON LE.LOID = AO.LOID
			INNER JOIN [dbo].[LinkOnline_EnrichedDetail] LED with (nolock) ON LED.TLOMEID = TLOME.TLOMEID
			INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID		
			WHERE 
			e.EventID in (154,	
155,	
156,	
157,	
158,	
159) AND LP.Date >= '2024-04-01 00:00:00' AND LP.Date <= '2025-04-16 23:00:00' 
			AND 
			(
					(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
				)
			--and TLOME.TLOMID in (select article_id from required_articleids_mahindra where article_id>0 and type='online')

			--select * from required_articleids_mahindra

			UNION ALL 

			select  distinct  tlom.TLPMID as article_id,e.EventID as incident_id
			,'Print' as Type
	--		,CASE 
 --       WHEN LOWER(Ao.text) LIKE '%truck%' 
 --         OR LOWER(Ao.text) LIKE '%bus%' 
 --         OR LOWER(Ao.text) LIKE '%buses%' 
 --         OR LOWER(Ao.text) LIKE '%tractor%' 
 --         OR LOWER(Ao.text) LIKE '%cvs%' 
 --         OR LOWER(Ao.text) LIKE '%commercial vehicle%' 
 --         OR LOWER(Ao.text) LIKE '%commercial evs%' 
 --         OR LOWER(Ao.text) LIKE '%lcv%' 
 --         OR LOWER(Ao.text) LIKE '%cargo%' 
 --         OR LOWER(Ao.text) LIKE '%construction%' 
 --         OR LOWER(Ao.text) LIKE '%3-wheeler%' 
 --         OR LOWER(Ao.text) LIKE '%bolero%' 
 --         OR LOWER(Ao.text) LIKE '%veero%' 
 --         OR LOWER(Ao.text) LIKE '%mahindra blazo%' 
 --         OR LOWER(Ao.text) LIKE '%maxx pik up%' 
 --         OR LOWER(Ao.text) LIKE '%agriculture%' 
 --         OR LOWER(Ao.text) LIKE '%farm%' 
 --         OR LOWER(Ao.text) LIKE '%auto-comp%' 
 --         OR LOWER(Ao.text) LIKE '%auto components%' 
 --         OR LOWER(Ao.text) LIKE '%last mile mobility%' 
 --         OR LOWER(Ao.text) LIKE '%rickshaw%' 
 --         OR LOWER(Ao.text) LIKE '%e-rickshaw%' 
 --       THEN 'Yes'
 --       ELSE 'No'
 --   END AS Is_Not_PV,

 --   CASE 
 --       WHEN LOWER(Ao.text) LIKE '%tech mahindra%' 
 --         OR LOWER(Ao.text) LIKE '%mahindra lifespaces%' 
 --         OR LOWER(Ao.text) LIKE '%kotak mahindra%' 
 --         OR LOWER(Ao.text) LIKE '%kotak amc%' 
 --         OR LOWER(Ao.text) LIKE '%mahindra logistics%' 
 --         OR LOWER(Ao.text) LIKE '%mahindra finance%' 
 --         OR LOWER(Ao.text) LIKE '%mahindra armado%' 
 --         OR LOWER(Ao.text) LIKE '%activa%' 
 --         OR LOWER(Ao.text) LIKE '%jawa 350%' 
 --         OR LOWER(Ao.text) LIKE '%hero electra%' 
 --         OR LOWER(Ao.text) LIKE '%bajaj%' 
 --         OR LOWER(Ao.text) LIKE '%tvs%' 
 --       THEN 'Yes'
 --       ELSE 'No'
 --   END AS Is_Not_Relevant_Company
	--,case when LOWER(Ao.text) LIKE '%XUV700%' OR LOWER(Ao.text) LIKE '%XUV 700%'  then 'Yes' ELSE 'No' end as 'XUV700'
	--,case when LOWER(Ao.text) LIKE '%Scorpio-N%'  then 'Yes' ELSE 'No' end as 'Scorpio-N'
	--,case when LOWER(Ao.text) LIKE '%Thar ROXX%'  then 'Yes' ELSE 'No' end as 'Thar_ROXX'
	--,case when LOWER(Ao.text) LIKE '%XUV 3XO%'  then 'Yes' ELSE 'No' end as 'XUV_3XO'
	--,case when LOWER(Ao.text) LIKE '%BE 6%'  then 'Yes' ELSE 'No' end as 'BE_6'
	--,case when LOWER(Ao.text) LIKE '%XEV 9e%'  then 'Yes' ELSE 'No' end as 'XEV_9e'
	,case when LOWER(Ao.text) LIKE '%Bolero%'  then 'Yes' ELSE 'No' end as 'Bolero'
			FROM dbo.LinkPrint AO with (nolock)
			INNER JOIN [dbo].mstPublication P WITH (NOLOCK) ON p.PublicationID = AO.PublicationID
			INNER JOIN [dbo].[TagLinkPrintMap] tlom WITH (NOLOCK) ON tlom.LPID=AO.LPID INNER JOIN [dbo].[TagLinkPrintMapE] tlome WITH (NOLOCK) ON TLOME.TLPMID=tlom.TLPMID
			INNER JOIN [dbo].[LinkPrint_Enriched] LE with (nolock) ON LE.LPID = AO.LPID
			INNER JOIN [dbo].LinkPrint_Enriched_ArticleType LEA with (nolock) ON LEA.LPEID = LE.LPEID			
			INNER JOIN [dbo].[LinkPrint_EnrichedDetail] LED with (nolock) ON LED.TLPMEID = TLOME.TLPMEID
			INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
			WHERE 
			e.EventID in (154,	
155,	
156,	
157,	
158,	
159	)  AND 
			AO.NewsDate >= '2024-04-01 00:00:00' AND AO.NewsDate <= '2025-04-14 23:00:00'
			AND (
				(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
			)
			--and tlom.TLPMID in (select article_id from required_articleids_mahindra where article_id>0 and type='Print')


			


