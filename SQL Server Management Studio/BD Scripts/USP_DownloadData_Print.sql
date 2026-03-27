select distinct 
tlom.TLPMID as [Article ID]
,AO.NewsDate  as [Date - Time]
,'http://print.adfactorspr.com/NewsDetailsPublished.aspx?NewsID='+AO.Url as [URL]
,AO.Title as [Title]
,p.Publication as [Publication Name]
,case 
				WHEN MLPA.Agency IS NOT NULL THEN ltrim(rtrim(MLPA.Agency))
				WHEN AO.Source IS NOT NULL THEN ltrim(rtrim(AO.Source))
				WHEN MLPJ.JournalistName IS NOT NULL THEN ltrim(rtrim(MLPJ.JournalistName))
				else 'NA'
			END	  as [Author]
,LE.Summary as [Article Summary]
,stuff((SELECT  ',' + mstLinkPrintEdition.Edition
				FROM LinkPrint_Edition 
				INNER JOIN mstLinkPrintEdition with (nolock) ON  mstLinkPrintEdition.EditionID = LinkPrint_Edition.EditionID
				WHERE LinkPrint_Edition.LPID = AO.LPID
				FOR XML PATH('')),1,1,'') AS [Edition]
,isnull(p.Type,'NA') as [Publication Type]
,stuff((SELECT ',' +LinkPrint_Image.PageNo 
				FROM LinkPrint_Image 
				WHERE LinkPrint_Image.LPID = AO.LPID
				FOR XML PATH('')),1,1,'') AS [Page No]
,(ISNULL(LED.[client_name_in_headline],0)) as [Headline Mention]
,replace(isnull(LED.headline_sentiments,'Neutral'),'None','Neutral') as [Headline Sentiment]
,LED.Sentiment as [Article Sentiment]
,stuff((SELECT  ',' + mstLinkPrintEdition.Edition
				FROM LinkPrint_Edition 
				INNER JOIN mstLinkPrintEdition with (nolock) ON  mstLinkPrintEdition.EditionID = LinkPrint_Edition.EditionID
				WHERE LinkPrint_Edition.LPID = AO.LPID
				FOR XML PATH('')),1,1,'') AS [Publication Edition]
,isnull(circulationscore,0)  as [Publication Circulation]
,LED.Impact_Score as [Impact Score]
,isnull(AVE,0) as [AVE]
,ltrim(rtrim(AO.Source)) as [Source]
,replace(LED.Article_Mention,' Mention','') as [Mention Type]
,case when B.BookmarkID is null then 0 else 1 end as [Bookmarked]
,stuff((SELECT ',' + ISNULL(MATE.ArticleType, 'NA')
	FROM [dbo].[LinkPrint_Enriched_ArticleType] LPEA WITH (NOLOCK)
	LEFT JOIN [dbo].[mstArticleType_Enriched] MATE WITH (NOLOCK) ON MATE.ArticleTypeID = LPEA.ArticleTypeID
	WHERE  LPEA.LPEID = LE.LPEID
	FOR XML PATH('')),1,1,'') AS ArticleType
,stuff((SELECT ',' + ISNULL(MADC.Category, 'NA')
	FROM [dbo].[LinkPrint_Enriched_DiscourseCategory] LPEDC WITH (NOLOCK) 
	LEFT JOIN [dbo].[mstArticleDiscourseCategory_Enriched] MADC WITH (NOLOCK) ON MADC.DiscourseCategoryID = LPEDC.DiscourseCategoryID 
	WHERE  LPEDC.LPEID = LE.LPEID
	FOR XML PATH('')),1,1,'') AS discourse_category
,client_name_in_headline as [Client name in Headline]
,Is_CompetitionPresent as [Competition Present]
,Competitor_Name as [Competitor Name]
,SpokePerson_Name as [Spokesperson Name]
,Spokesperson_statement_quote as [Spokesperson Statement]
,Other_Spokeperson as [Other Spokesperson]
,lan.[Language] as [Language]
,( CASE WHEN (SELECT COUNT(1)
	  FROM [dbo].[LinkPrint_Enriched_ArticleType] LPEA WITH (NOLOCK)
	  WHERE LPEA.LPEID = LE.LPEID AND LPEA.ArticleTypeID = 21)>0 THEN 1 ELSE 0 END
	) AS [Stock News]
,AO.NewsDate as date_sort,isnull(circulationscore,0) as circulation_sort,isnull(AVE,0) as ave_sort,LED.Impact_Score as pi_score_sort

			FROM dbo.LinkPrint AO with (nolock)
			INNER JOIN [dbo].mstPublication P WITH (NOLOCK) ON p.PublicationID = AO.PublicationID
			LEFT JOIN [dbo].mstLinkPrintAgency MLPA WITH (NOLOCK) ON MLPA.AgencyID=AO.AgencyID
			LEFT JOIN LinkPrint_Journalist LPJ WITH(NOLOCK) ON AO.LPID=LPJ.LPID
			LEFT JOIN mstLinkPrintJournalist MLPJ WITH(NOLOCK) ON MLPJ.JournalistID=LPJ.JournalistID
			INNER JOIN [dbo].[TagLinkPrintMap] tlom WITH (NOLOCK) ON tlom.LPID=AO.LPID INNER JOIN [dbo].[TagLinkPrintMapE] tlome WITH (NOLOCK) ON TLOME.TLPMID=tlom.TLPMID
			INNER JOIN [dbo].[LinkPrint_Enriched] LE with (nolock) ON LE.LPID = AO.LPID
			INNER JOIN [dbo].LinkPrint_Enriched_ArticleType LEA with (nolock) ON LEA.LPEID = LE.LPEID
			INNER JOIN [dbo].mstArticleType_Enriched ME with (nolock) ON ME.ArticleTypeID = LEA.ArticleTypeID
			INNER JOIN [dbo].[LinkPrint_EnrichedDetail] LED with (nolock) ON LED.TLPMEID = TLOME.TLPMEID
			INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
			LEFT JOIN [dbo].[Bookmark] B WITH (NOLOCK) on tlom.TLPMID= B.RecordID and PlatformID=2 AND (634 = 0 OR B.UserID =634)
			LEFT JOIN [dbo].[mstLanguage] lan with (nolock) ON lan.LanguageID = LE.LanguageID
			WHERE e.EventID=10 AND AO.NewsDate >= '2025-01-01 00:00:00' AND AO.NewsDate <= '2025-03-01 00:00:00' 
			AND (
				(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
			)