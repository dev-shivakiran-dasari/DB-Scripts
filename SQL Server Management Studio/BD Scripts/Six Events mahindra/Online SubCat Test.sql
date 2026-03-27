

WITH CTE_TEMPDATA
AS
(select distinct tlom.TLOMID as article_id,e.EventID as incident_id,e.EventName
			
			,LP.Title as Title
			,TLOME.TLOMEID
			 ,[Is_Relevant_About_Client]
      ,[Is_Relevant_About_Topic]
      ,[Article_Mention]
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
			WHERE e.EventID=155 AND LP.Date >= '2024-04-01 00:00:00' AND LP.Date <= '2025-04-16 23:00:00' 
			AND (
					(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
				)
			
),CTE_#Temp_Tags AS
(
			
select  ROW_NUMBER() over(partition by TLOMEID order by TLOMEID  ) as RN,*  from [dbo].[Tags_Hyundai] where TLOMEID in (select TLOMEID from CTE_TEMPDATA)
			)

			select distinct 'Online' as Type, article_id, incident_id,EventName
			,Title
			,[Classifier_StockNews]
      ,[Classifier_AlsoRead]
      ,[Classifier_ScooterOnly]
      ,[Classifier_ScooterBrands]
      ,[Classifier_IsNonNews]
	  ,Category
	  --,SubCategory
       from CTE_TEMPDATA a with(nolock)
	   LEFT join LinkOnline_Enriched_Category LOEC with(nolock) on a.TLOMEID=LOEC.TLOMEID
			left JOIN CTE_#Temp_Tags th with(nolock) on th.TLOMEID=a.TLOMEID and RN=1
			

			