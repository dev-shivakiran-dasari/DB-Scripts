

declare @eventid int =158
,@from_date DATETIME ='2026-01-01 00:00:00' 
,@to_date DATETIME ='2026-01-31 23:00:00'  


;WITH Temp_facttable as(
select tlome_id 
	from fact_online with (nolock)
	where event_id =@eventid
		and date_time >= @from_date
		and date_time <= @to_date
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

select distinct tlom.TLOMID as article_id,e.EventID as incident_id,AO.Url as url,
			LP.Title as title
			,LE.Summary as description
			,REPLACE(CONVERT(NVARCHAR,LP.Date, 106), ' ', '-') + ' | '+ LTRIM(RIGHT(CONVERT(VARCHAR(20), LP.Date, 100), 7)) as date_time,
			isnull(MLOA.AuthorName,'NA') as author,LED.Sentiment as sentiment,
			p.Publication as publication,
			'https://www.google.com/s2/favicons?domain='+p.Publication as publication_icon,
			isnull(p.PublicationCategory,'NA') as publication_category,
			isnull(p.Type,'NA') as publication_type,
			convert(varchar(100),isnull(p.DA,0))+'/100' as publication_da,dbo.GetFormat(isnull(p.TotalVisits,0)) as publication_traffic,
			convert(varchar(100),isnull(LED.Impact_Score,3))+'/10' as pi_score
			,LP.Date as date_sort,isnull(p.DA,0) as da_sort,isnull(p.TotalVisits,0) as traffic_sort,isnull(LED.Impact_Score,0) as pi_score_sort,
			replace(LED.Article_Mention,' Mention','') as mention_type,--replace(LED.Article_Mention,' Type','')
			case when B.BookmarkID is null then 0 else 1 end as is_bookmarked
			,LED.headline_sentiments as headline_sentiment	  
			INTO ExcelOnlineData_TataMotors_02Feb2026
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
			LEFT JOIN mstLanguage lan  with (nolock) ON lan.LanguageID = LE.LanguageID
			OUTER APPLY(select MAX(Category) as Category 	FROM [dbo].[LinkOnline_Enriched_DiscourseCategory] LOEDC WITH (NOLOCK)
					INNER JOIN [dbo].[mstArticleDiscourseCategory_Enriched] MADCE WITH (NOLOCK) ON LE.LOEID = LOEDC.LOEID and MADCE.DiscourseCategoryID = LOEDC.DiscourseCategoryID
					GROUP BY LOEDC.LOEID) as DisCat
			OUTER APPLY(select MAX(ArticleType) as ArticleType 	FROM LinkOnline_Enriched_ArticleType LOEAT  WITH (NOLOCK)
					INNER JOIN mstArticleType_Enriched MATE  WITH (NOLOCK) ON LE.LOEID = LOEAT.LOEID and LOEAT.ArticleTypeID = MATE.ArticleTypeID
					GROUP BY LOEAT.LOEID) as tblArticleType
			WHERE e.EventID = @eventid AND LP.Date >= @from_date AND LP.Date <= @to_date
			


			--select * from Event where EventID in (153,154,155,156,157,158)
			--select * from Event where EventID in (2345,2348,2349,2350,2351,2352)


			

--SELECT  distinct tlom.TLOMID as article_id,
--TLOME.TLOMEID,
--AO.LOID,
--Publication,e.TagID,
--    FORMAT(LP.Date, 'MM/dd/yyyy') AS [Date],
--    FORMAT(LP.Date, 'HH:mm') AS [Time],
--	'' as [Document ID],
--	AO.Url as [URL],
--	'' AS [Input Name],
--	'' as [Keywords],
--	'news' as [Information Type],
--	'online news' as [Source Type],
--	Publication as [Source Name],
--	Publication as [Source Domain],
--	'News Article' as [Content Type],
--	isnull(MLOA.AuthorName,'NA') as [Author Name],
--	'' as [Author Handle],
--	isnull(Isnull(left(LP.Title,100),isnull(left(LP.Title,100),NULL)),'') as [Title],
--	LE.Summary as [Opening Text],
--	ShortSummary as [Hit Sentence],
--	'' as [Image],
--	'' as [Hashtags],
--	'' as [Links],
--	P.Country as [Country],
--	'' as [Region],
--	'' as [State],
--	'' as [City],
--	P.Language as [Language],
--	LED.Sentiment as [Sentiment],
--	'' as [Keyphrases],
--	dbo.GetFormat(isnull(p.TotalVisits,0)) AS [Reach] ,
--	dbo.GetFormat(CONVERT(INT,(isnull(p.TotalVisits,0) * 0.025 * 0.35 * 1 * (CASE WHEN LED.client_name_in_headline = 'Mentioned' THEN 1.5 ELSE 1 END) * 3))) as AVE,
--	'' as [Social Echo],
--	'' as [Editorial Echo],
--	'' as [Engagement],
--	'' as [Shares],
--	'' as [Quotes],
--	'' as [Likes],
--	'' as [Replies],
--	'' as [Reposts],
--	'' as [Comments],
--	'' as [Reactions],
--	'' as [Views],
--	'' as [Estimated Views],
--	'' as [Document Tags],
--	'' as [Custom Categories]



