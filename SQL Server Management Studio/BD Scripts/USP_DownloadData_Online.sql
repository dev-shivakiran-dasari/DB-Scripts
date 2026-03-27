select 
LP.Date  as [Date - Time]
,AO.Url as [URL]
,isnull(Isnull(left(LP.Title,100),isnull(left(LP.Title,100),NULL)),'') as [Title]
,p.Publication as Publication
,isnull(MLOA.AuthorName,'NA') as [Author]
,LE.Summary as [Article Summary]
,(ISNULL(LED.[client_name_in_headline],0)) as [Headline Mention]
,LED.headline_sentiments as [Headline Sentiment]
,LED.Sentiment as [Article Sentiment]
,isnull(p.Type,'NA') as [Article Sentiment]
,isnull(p.DA,0) as [Publication Domain Authority]
,isnull(p.TotalVisits,0) as [Publication Traffic]
,isnull(LED.Impact_Score,0) as [Impact Score]
,replace(LED.Article_Mention,' Mention','') as [Mention Type]
,case when B.BookmarkID is null then 0 else 1 end as [Bookmarked]
,stuff((SELECT ',' + ISNULL(MATE.ArticleType, 'NA')
	FROM [dbo].[LinkOnline_Enriched_ArticleType] LOEA WITH (NOLOCK)
	LEFT JOIN [dbo].[mstArticleType_Enriched] MATE WITH (NOLOCK) ON MATE.ArticleTypeID = LOEA.ArticleTypeID
	WHERE  LOEA.LOEID = LE.LOEID
	FOR XML PATH('')),1,1,'') AS ArticleType
,stuff((SELECT ',' + ISNULL(MADC.Category, 'NA')
	FROM [dbo].[LinkOnline_Enriched_DiscourseCategory] LOEDC WITH (NOLOCK) 
	LEFT JOIN [dbo].[mstArticleDiscourseCategory_Enriched] MADC WITH (NOLOCK) ON MADC.DiscourseCategoryID = LOEDC.DiscourseCategoryID 
	WHERE  LOEDC.LOEID = LE.LOEID
	FOR XML PATH('')),1,1,'') AS discourse_category
,client_name_in_headline as [Client name in Headline]
,Is_CompetitionPresent as [Competition Present]
,Competitor_Name as [Competitor Name]
,SpokePerson_Name as [Spokesperson Name]
,Spokesperson_statement_quote as [Spokesperson Statement]
,Other_Spokeperson as [Other Spokesperson]
,lan.[Language] as [Language]
,( CASE WHEN (SELECT COUNT(1)
	  FROM [dbo].[LinkOnline_Enriched_ArticleType] LOEA WITH (NOLOCK)
	  WHERE LOEA.LOEID = LE.LOEID AND LOEA.ArticleTypeID = 21)>0 THEN 1 ELSE 0 END
	) AS [Stock News]

FROM dbo.LinkOnline AO with (nolock)
INNER JOIN [dbo].[LinkOnline_Processed] LP WITH (NOLOCK) ON LP.LOPID=AO.LOPID
LEFT JOIN [dbo].mstLinkOnlineAuthor MLOA WITH (NOLOCK) ON MLOA.AuthorID=AO.AuthorID
INNER JOIN [dbo].mstPublication P WITH (NOLOCK) ON p.PublicationID = AO.PublicationID
INNER JOIN [dbo].[TagLinkOnlineMap] tlom WITH (NOLOCK) ON tlom.LOID=AO.LOID INNER JOIN [dbo].[TagLinkOnlineMapE] TLOME with(nolock) on TLOME.TLOMID=tlom.TLOMID
INNER JOIN [dbo].[LinkOnline_Enriched] LE with (nolock) ON LE.LOID = AO.LOID
INNER JOIN [dbo].[LinkOnline_EnrichedDetail] LED with (nolock) ON LED.TLOMEID = TLOME.TLOMEID
LEFT JOIN [dbo].[mstLanguage] lan with (nolock) ON lan.LanguageID = LE.LanguageID
INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
LEFT JOIN [dbo].[Bookmark] B WITH (NOLOCK) on tlom.TLOMID= B.RecordID and PlatformID=1 AND (634 = 0 OR B.UserID =634)
WHERE e.EventID=10 AND LP.Date >= '2025-03-27 05:30:00' AND LP.Date <= '2025-03-28 05:30:00'
AND (
		(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
	)
ORDER BY AO.Date desc