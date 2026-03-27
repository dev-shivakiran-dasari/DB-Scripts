


WITH Temp_facttable as(
select tlome_id 
	from fact_online with (nolock)
	where event_id in (153)
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


, CTE_TEMPDATA
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
	  ,lan.[Language],
	  --,[Is_Product_Brand]
   --   ,[Is_Leadership_Corporate]
   --   ,[Is_Financials]
   --   ,[Is_Manufacturing_Operations]
   --   ,[Is_ConsumerFacing_Initiatives]
   --   ,[Is_Legal_Compliance]
   --   ,[Is_Consumer_Education_Marketing_Content]
   --   ,[Is_Policy_Regulation]
   --   ,[Is_SectorLevel_MarketTrends]
   --   ,[Is_Technology_Innovation]
   --   ,[Is_Electronic_Hybridvehicles]
   --   ,[Is_SupplyChain_VendorEcosystem]
   --   ,[Is_Others]
   --   ,[Sub_Category]
   JSON_VALUE(dynamic_prompt_output, '$."Product & Brand"') AS [Is_Product_Brand],
    JSON_VALUE(dynamic_prompt_output, '$."Leadership & Corporate"') AS [Is_Leadership_Corporate],
    JSON_VALUE(dynamic_prompt_output, '$."Financials"') AS [Is_Financials],
    JSON_VALUE(dynamic_prompt_output, '$."Manufacturing & Operations"') AS [Is_Manufacturing_Operations],
    JSON_VALUE(dynamic_prompt_output, '$."Consumer-Facing Initiatives"') AS [Is_ConsumerFacing_Initiatives],
    JSON_VALUE(dynamic_prompt_output, '$."Legal / Compliance"') AS [Is_Legal_Compliance],
    JSON_VALUE(dynamic_prompt_output, '$."Consumer Education & Marketing Content"') AS [Is_Consumer_Education_Marketing_Content],
    JSON_VALUE(dynamic_prompt_output, '$."Policy & Regulation"') AS [Is_Policy_Regulation],
    JSON_VALUE(dynamic_prompt_output, '$."Sector-Level & Market Trends"') AS [Is_SectorLevel_MarketTrends],
    JSON_VALUE(dynamic_prompt_output, '$."Technology Innovation"') AS [Is_Technology_Innovation],
    JSON_VALUE(dynamic_prompt_output, '$."Electronic or hybrid vehicles"') AS [Is_Electronic_Hybridvehicles],
    JSON_VALUE(dynamic_prompt_output, '$."Supply Chain / Vendor Ecosystem"') AS [Is_SupplyChain_VendorEcosystem],
    JSON_VALUE(dynamic_prompt_output, '$."Others"') AS [Is_Others],
    JSON_VALUE(dynamic_prompt_output, '$."Sub Category"') AS [Sub_Category]

			----,MATE.ArticleType
			,    CASE 
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
			WHERE e.EventID=153 AND LP.Date >= '2025-04-01 00:00:00' AND LP.Date <= '2025-07-21 23:00:00' 
			--AND (
			--		(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
			--	)
			
),CTE_#Temp_Tags AS
(
			
select  ROW_NUMBER() over(partition by TLOMEID order by TLOMEID  ) as RN,*  from [dbo].[Tag_TataMotor_21072025] where TLOMEID in (select TLOMEID from CTE_TEMPDATA)
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
	  ,Is_Not_PV,
Is_Not_Relevant_Company,
XUV700,
[Scorpio-N],
Thar_ROXX,
XUV_3XO,
BE_6,
XEV_9e
       from CTE_TEMPDATA a with(nolock)
			left JOIN CTE_#Temp_Tags th with(nolock) on th.TLOMEID=a.TLOMEID and RN=1
			

--select * from event where eventid in (153,154,155,156,157,158,159)
-- select * from [dbo].[Tag_Hyundai_21072025]