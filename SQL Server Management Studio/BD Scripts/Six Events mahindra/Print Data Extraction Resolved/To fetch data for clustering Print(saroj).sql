
declare @eventid int=153


;with Temp_facttable as(
select TLPMEID 
		FROM [dbo].[fact_print] fp with(nolock)
		where eventid =@eventid
		and NewsDate >= '2025-04-01 00:00:00' 
		and NewsDate <= '2025-07-21 23:00:00'  
            AND ((Event_Type_ID = 1 AND Is_Relevant_About_Client = 1) 
                OR (--Is_Relevant_About_Client = 1 AND 
				Is_Relevant_About_Topic = 1))
)

select distinct tlom.TLPMID as article_id,e.EventID as incident_id,'http://print.adfactorspr.com/NewsDetailsPublished.aspx?NewsID='+AO.Url as url,
			AO.Title as title,LE.Summary as description,REPLACE(CONVERT(NVARCHAR,AO.NewsDate, 106), ' ', '-') as date_time,
			case 
				WHEN MLPA.Agency IS NOT NULL THEN ltrim(rtrim(MLPA.Agency))
				WHEN AO.Source IS NOT NULL THEN ltrim(rtrim(AO.Source))
				WHEN MLPJ.JournalistName IS NOT NULL THEN ltrim(rtrim(MLPJ.JournalistName))
				else 'NA'
			END	  as author,
			stuff((SELECT  ',' + mstLinkPrintEdition.Edition
				FROM LinkPrint_Edition 
				INNER JOIN mstLinkPrintEdition with (nolock) ON  mstLinkPrintEdition.EditionID = LinkPrint_Edition.EditionID
				WHERE LinkPrint_Edition.LPID = AO.LPID
				FOR XML PATH('')),1,1,'') AS edition,
			stuff((SELECT ',' +LinkPrint_Image.PageNo 
				FROM LinkPrint_Image 
				WHERE LinkPrint_Image.LPID = AO.LPID
				FOR XML PATH('')),1,1,'') AS page_no,LED.Sentiment as sentiment,
			p.Publication as publication_name,'' as publication_icon,isnull(p.Type,'NA') as publication_type,'' as publication_category,
			replace(dbo.GetFormat(isnull(circulationscore,0)),' views','') as publication_circulation,
			convert(varchar(100),LED.Impact_Score)+'/10' as pi_score,
			replace(dbo.GetFormat(isnull(AVE,0)),' views','') as ave
			,AO.NewsDate as date_sort,isnull(circulationscore,0) as circulation_sort,isnull(AVE,0) as ave_sort,replace(LED.Article_Mention,' Mention','') as mention_type,
			case when B.BookmarkID is null then 0 else 1 end as is_bookmarked
			,replace(isnull(LED.headline_sentiments,'Neutral'),'None','Neutral') as headline_sentiment,LED.Impact_Score as pi_score_sort
			FROM dbo.LinkPrint AO with (nolock)
			INNER JOIN [dbo].mstPublication P WITH (NOLOCK) ON p.PublicationID = AO.PublicationID
			LEFT JOIN [dbo].mstLinkPrintAgency MLPA WITH (NOLOCK) ON MLPA.AgencyID=AO.AgencyID
			LEFT JOIN LinkPrint_Journalist LPJ WITH(NOLOCK) ON AO.LPID=LPJ.LPID
			LEFT JOIN mstLinkPrintJournalist MLPJ WITH(NOLOCK) ON MLPJ.JournalistID=LPJ.JournalistID
			INNER JOIN [dbo].[TagLinkPrintMap] tlom WITH (NOLOCK) ON tlom.LPID=AO.LPID INNER JOIN [dbo].[TagLinkPrintMapE] tlome WITH (NOLOCK) ON TLOME.TLPMID=tlom.TLPMID
			INNER JOIN Temp_facttable ft WITH (NOLOCK) ON ft.tlpmeid=tlome.TLPMEID
			INNER JOIN [dbo].[LinkPrint_Enriched] LE with (nolock) ON LE.LPID = AO.LPID
			INNER JOIN [dbo].LinkPrint_Enriched_ArticleType LEA with (nolock) ON LEA.LPEID = LE.LPEID			
			INNER JOIN [dbo].[LinkPrint_EnrichedDetail] LED with (nolock) ON LED.TLPMEID = TLOME.TLPMEID
			INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
			LEFT JOIN [dbo].[Bookmark] B WITH (NOLOCK) on tlom.TLPMID= B.RecordID and PlatformID=2 AND (634 = 0 OR B.UserID =634)
			LEFT JOIN mstLanguage lan  with (nolock) ON lan.LanguageID = LE.LanguageID
			OUTER APPLY(select MAX(Category) as Category 	FROM [dbo].[LinkPrint_Enriched_DiscourseCategory] LOEDC WITH (NOLOCK)
					INNER JOIN [dbo].[mstArticleDiscourseCategory_Enriched] MADCE WITH (NOLOCK) ON LE.LPEID = LOEDC.LPEID and MADCE.DiscourseCategoryID = LOEDC.DiscourseCategoryID
					GROUP BY LOEDC.LPEID) as DisCat
			OUTER APPLY(select MAX(ArticleType) as ArticleType 	FROM LinkPrint_Enriched_ArticleType LPEAT  WITH (NOLOCK)
					INNER JOIN mstArticleType_Enriched MATE  WITH (NOLOCK) ON LE.LPEID = LPEAT.LPEID and LPEAT.ArticleTypeID = MATE.ArticleTypeID
					GROUP BY LPEAT.LPEID) as tblArticleType
			WHERE e.EventID=@eventid AND AO.NewsDate >= '2025-04-01 00:00:00' AND AO.NewsDate <= '2025-07-24 23:00:00'
			
			--select * from Event where EventID=158