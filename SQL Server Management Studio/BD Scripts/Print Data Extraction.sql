


WITH CTE_TEMPDATA
AS
(select distinct tlom.TLPMID as article_id,e.EventID as incident_id,'http://print.adfactorspr.com/NewsDetailsPublished.aspx?NewsID='+AO.Url as url,
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
			,tblArticleType.ArticleType as ArticleType
			, DisCat.Category  as DiscourseCategory
			,TLOME.TLPMEID
			 ,[Is_Relevant_About_Client]
      ,[Is_Relevant_About_Topic]
      ,[Article_Mention]
      ,[Sentiment_Score]
      ,[Sentiment_Explanation]
      ,[Is_CompetitionPresent]
      ,[Competitor_Name]
      ,[SpokePerson_Name]
      ,[Spokesperson_statement_quote]
      ,[Other_Spokeperson]
      ,[headline_sentiments]
      ,[headline_negative_score]
      ,[headline_negative_explanation]
      ,[headline_article_sentiment_match]
      ,[client_name_in_headline]
	  ,lan.[Language]
	  ,Publication
	  ,[Is_Product_Brand]
      ,[Is_Leadership_Corporate]
      ,[Is_Financials]
      ,[Is_Manufacturing_Operations]
      ,[Is_ConsumerFacing_Initiatives]
      ,[Is_Legal_Compliance]
      ,[Is_Consumer_Education_Marketing_Content]
      ,[Is_Policy_Regulation]
      ,[Is_SectorLevel_MarketTrends]
      ,[Is_Technology_Innovation]
      ,[Is_Electronic_Hybridvehicles]
      ,[Is_SupplyChain_VendorEcosystem]
      ,[Is_Others]
      ,[Sub_Category]
			
			FROM dbo.LinkPrint AO with (nolock)
			INNER JOIN [dbo].mstPublication P WITH (NOLOCK) ON p.PublicationID = AO.PublicationID
			LEFT JOIN [dbo].mstLinkPrintAgency MLPA WITH (NOLOCK) ON MLPA.AgencyID=AO.AgencyID
			LEFT JOIN LinkPrint_Journalist LPJ WITH(NOLOCK) ON AO.LPID=LPJ.LPID
			LEFT JOIN mstLinkPrintJournalist MLPJ WITH(NOLOCK) ON MLPJ.JournalistID=LPJ.JournalistID
			INNER JOIN [dbo].[TagLinkPrintMap] tlom WITH (NOLOCK) ON tlom.LPID=AO.LPID INNER JOIN [dbo].[TagLinkPrintMapE] tlome WITH (NOLOCK) ON TLOME.TLPMID=tlom.TLPMID
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
			WHERE e.EventID=159 AND AO.NewsDate >= '2024-04-01 00:00:00' AND AO.NewsDate <= '2025-04-14 23:00:00'
			AND (
				(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
			)
			
)


			select  
			article_id,incident_id,a.url,
			title,description,date_time,
			 author,
			edition,
			sentiment,
			publication_name, publication_type,
			publication_circulation,
			pi_score,
			ave
			,date_sort,circulation_sort,ave_sort, mention_type,
			 is_bookmarked
			,headline_sentiment,pi_score_sort
			,ArticleType
			,a.TLPMEID
      
	   ,[Is_Relevant_About_Client]
      ,[Is_Relevant_About_Topic]
      ,[Article_Mention]
      
      ,[Sentiment_Score]
      ,[Sentiment_Explanation]
      ,[Is_CompetitionPresent]
      ,[Competitor_Name]
      ,[SpokePerson_Name]
      ,[Spokesperson_statement_quote]
      ,[Other_Spokeperson]
      ,[headline_sentiments]
      ,[headline_negative_score]
      ,[headline_negative_explanation]
      ,[headline_article_sentiment_match]
      ,[client_name_in_headline]
	  ,[Language]
	  ,[Is_Product_Brand]
      ,[Is_Leadership_Corporate]
      ,[Is_Financials]
      ,[Is_Manufacturing_Operations]
      ,[Is_ConsumerFacing_Initiatives]
      ,[Is_Legal_Compliance]
      ,[Is_Consumer_Education_Marketing_Content]
      ,[Is_Policy_Regulation]
      ,[Is_SectorLevel_MarketTrends]
      ,[Is_Technology_Innovation]
      ,[Is_Electronic_Hybridvehicles]
      ,[Is_SupplyChain_VendorEcosystem]
      ,[Is_Others]
      ,[Sub_Category]
       from CTE_TEMPDATA a with(nolock)
			--left JOIN CTE_#Temp_Tags th with(nolock) on th.TLOMEID=a.TLPMEID and RN=1
			


			--,CTE_#Temp_Tags AS
--(
			
--select  ROW_NUMBER() over(partition by TLOMEID order by TLOMEID  ) as RN,*  from [dbo].[Tags_Hyundai] where TLOMEID in (select TLOMEID from CTE_TEMPDATA)
			--)