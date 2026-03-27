

WITH CTE_TEMPDATA
AS
(select distinct tlom.TLOMID as article_id,e.EventID as incident_id,AO.Url as url,
			isnull(Isnull(left(LP.Title,100),isnull(left(LP.Title,100),NULL)),'') as title
			,LP.Title as full_Title
			,ShortSummary
			,LE.Summary as description
			,REPLACE(CONVERT(NVARCHAR,LP.Date, 106), ' ', '-') + ' | '+ LTRIM(RIGHT(CONVERT(VARCHAR(20), LP.Date, 100), 7)) as date_time,
			isnull(MLOA.AuthorName,'NA') as author,LED.Sentiment as sentiment,
			p.Publication as publication,
			'https://www.google.com/s2/favicons?domain='+p.Publication as publication_icon,
			--isnull(p.PublicationCategory,'NA') as publication_category,
			isnull(p.Type,'NA') as publication_type,
			convert(varchar(100),isnull(p.DA,0))+'/100' as publication_da,dbo.GetFormat(isnull(p.TotalVisits,0)) as publication_traffic,
			convert(varchar(100),isnull(LED.Impact_Score,3))+'/10' as pi_score
			,LP.Date as date_sort,isnull(p.DA,0) as da_sort,isnull(p.TotalVisits,0) as traffic_sort,isnull(LED.Impact_Score,0) as pi_score_sort,
			replace(LED.Article_Mention,' Mention','') as mention_type,--replace(LED.Article_Mention,' Type','')
			case when B.BookmarkID is null then 0 else 1 end as is_bookmarked
			,LED.headline_sentiments as headline_sentiment
			, DisCat.Category  as DiscourseCategory,tblArticleType.ArticleType as ArticleType
			,TLOME.TLOMEID
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
			--,MATE.ArticleType
			
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
			WHERE e.EventID=159 AND LP.Date >= '2024-04-01 00:00:00' AND LP.Date <= '2025-04-16 23:00:00' 
			AND (
					(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
				)
			
),CTE_#Temp_Tags AS
(
			
select  ROW_NUMBER() over(partition by TLOMEID order by TLOMEID  ) as RN,*  from [dbo].[Tags_TataMotors] where TLOMEID in (select TLOMEID from CTE_TEMPDATA)
			)

			select  article_id, incident_id, a.url,title
			,full_Title,ShortSummary
			, description,
			 date_time,
			 sentiment,
			 ISNULL(th.[Publication],a.publication) as publication,
			 publication_icon,
			 publication_type,
			publication_da, publication_traffic,
			pi_score
			,date_sort, da_sort, traffic_sort, pi_score_sort,
			 mention_type,--replace(LED.Article_Mention,' Type','')
			is_bookmarked
			,headline_sentiment
			,DiscourseCategory,ArticleType
			,a.TLOMEID
			
			,[Classifier_StockNews]
      ,[Classifier_AlsoRead]
      ,[Classifier_Reach_LessThan500]
      ,[Classifier_Reach_MoreThan10000]
      ,[Classifier_URL_ContentType]
      ,[Classifier_TradeMedia]
      ,[Classifier_Client]
      ,[Classifier_Client_ProductMention]
      ,[Classifier_OtherCompanies]
      ,[Classifier_ScooterOnly]
      ,[Classifier_Accident]
      ,[Classifier_Review]
      ,[Classifier_IPO]
      ,[Classifier_Exports]
      ,[Classifier_AutoExpo]
      ,[Classifier_Launch]
      ,[Classifier_ScooterBrands]
      ,[Classifier_LuxuryBrands]
      ,[Classifier_Festive]
      ,[Classifier_Manufacture]
      ,[Classifier_PreOwned]
      ,[Classifier_SectorSpecific]
      ,[Classifier_CompetitorProducts]
      ,[Classifier_IsNonNews]
      ,[LOID]
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
			left JOIN CTE_#Temp_Tags th with(nolock) on th.TLOMEID=a.TLOMEID and RN=1
			
