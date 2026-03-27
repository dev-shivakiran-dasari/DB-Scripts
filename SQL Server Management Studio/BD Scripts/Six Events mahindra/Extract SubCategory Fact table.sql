

--select * from LinkPrint_Enriched_Category order by CreatedAt desc


WITH Temp_facttable AS(
		select TLPMEID
		FROM [dbo].[fact_print] fp with(nolock)
		where eventid in (153,154,155,156,157,158)
		and NewsDate >= '2025-04-01 00:00:00' 
		and NewsDate <= '2025-07-21 23:00:00'  
        AND ((Event_Type_ID = 1 AND Is_Relevant_About_Client = 1) 
        OR (--Is_Relevant_About_Client = 1 AND 
		Is_Relevant_About_Topic = 1))
		)
select TLOME.TLPMID as article_id,e.EventID,e.EventName,LOEC.* from LinkPrint_Enriched_Category LOEC
INNER JOIN [dbo].[TagLinkPrintMapE] TLOME with(nolock) on TLOME.TLPMEID=LOEC.TLPMEID
INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
where LOEC.TLPMEID in (
select tlome.TLPMEID
			FROM dbo.LinkPrint AO with (nolock)
			INNER JOIN [dbo].mstPublication P WITH (NOLOCK) ON p.PublicationID = AO.PublicationID
			LEFT JOIN [dbo].mstLinkPrintAgency MLPA WITH (NOLOCK) ON MLPA.AgencyID=AO.AgencyID
			LEFT JOIN LinkPrint_Journalist LPJ WITH(NOLOCK) ON AO.LPID=LPJ.LPID
			LEFT JOIN mstLinkPrintJournalist MLPJ WITH(NOLOCK) ON MLPJ.JournalistID=LPJ.JournalistID
			INNER JOIN [dbo].[TagLinkPrintMap] tlom WITH (NOLOCK) ON tlom.LPID=AO.LPID INNER JOIN [dbo].[TagLinkPrintMapE] tlome WITH (NOLOCK) ON TLOME.TLPMID=tlom.TLPMID
			INNER JOIN Temp_facttable ft WITH (NOLOCK) ON ft.tlpmeid=tlome.TLPMEID
			INNER JOIN [dbo].[LinkPrint_Enriched] LE with (nolock) ON LE.LPID = AO.LPID
			INNER JOIN [dbo].LinkPrint_Enriched_ArticleType LEA with (nolock) ON LEA.LPEID = LE.LPEID
			INNER JOIN [dbo].mstArticleType_Enriched ME with (nolock) ON ME.ArticleTypeID = LEA.ArticleTypeID
			INNER JOIN [dbo].[LinkPrint_EnrichedDetail] LED with (nolock) ON LED.TLPMEID = TLOME.TLPMEID
			INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
			LEFT JOIN [dbo].[Bookmark] B WITH (NOLOCK) on tlom.TLPMID= B.RecordID and PlatformID=1 AND (634 = 0 OR B.UserID =634)
			WHERE e.EventID in (153,154,155,156,157,158)  AND AO.NewsDate >= '2025-04-01 00:00:00' AND AO.NewsDate <= '2025-07-21 23:00:00' 
			AND (
					(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(--LED.Is_Relevant_About_Client = 1 AND 
					LED.Is_Relevant_About_Topic = 1)
				))
Order By e.eventID,LOEC.TLPMEID








		WITH Temp_facttable as (select tlome_id 
		from fact_online with (nolock)
		where event_id in (153,154,155,156,157,158)
		and date_time >= '2025-04-01 00:00:00' 
		and date_time <= '2025-07-21 23:00:00'  
		and 
		(
			(
				event_type_id = 1 
				and is_relevant_about_client = 1
			)
			OR 	
			(
				--is_relevant_about_client = 1 and 
				is_relevant_about_topic = 1
			)
		)
		)
select TLOME.TLOMID as article_id,e.EventID,e.EventName,LOEC.* from LinkOnline_Enriched_Category LOEC
INNER JOIN [dbo].[TagLinkOnlineMapE] TLOME with(nolock) on TLOME.TLOMEID=LOEC.TLOMEID
INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
where LOEC.TLOMEID in (
select tlome.tlomeid
			FROM dbo.LinkOnline AO with (nolock)
			INNER JOIN [dbo].[LinkOnline_Processed] LP WITH (NOLOCK) ON LP.LOPID=AO.LOPID
			LEFT JOIN [dbo].mstLinkOnlineAuthor MLOA WITH (NOLOCK) ON MLOA.AuthorID=AO.AuthorID
			INNER JOIN [dbo].mstPublication P WITH (NOLOCK) ON p.PublicationID = AO.PublicationID
			INNER JOIN [dbo].[TagLinkOnlineMap] tlom WITH (NOLOCK) ON tlom.LOID=AO.LOID INNER JOIN [dbo].[TagLinkOnlineMapE] TLOME with(nolock) on TLOME.TLOMID=tlom.TLOMID
			INNER JOIN Temp_facttable ft WITH (NOLOCK) ON ft.tlome_id=tlome.TLOMEID
			INNER JOIN [dbo].[LinkOnline_Enriched] LE with (nolock) ON LE.LOID = AO.LOID
			INNER JOIN [dbo].[LinkOnline_EnrichedDetail] LED with (nolock) ON LED.TLOMEID = TLOME.TLOMEID
			INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
			LEFT JOIN [dbo].[Bookmark] B WITH (NOLOCK) on tlom.TLOMID= B.RecordID and PlatformID=1 AND (634 = 0 OR B.UserID =634)
			WHERE e.EventID in (153,154,155,156,157,158) AND LP.Date >= '2025-04-01 00:00:00' AND LP.Date <= '2025-07-21 23:00:00' 
			AND (
					(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(--LED.Is_Relevant_About_Client = 1 AND 
					LED.Is_Relevant_About_Topic = 1)
				))
Order By e.eventID,LOEC.TLOMEID