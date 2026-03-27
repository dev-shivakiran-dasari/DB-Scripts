

declare @EventID INT=158


;with Temp_facttable as(
select TLPMEID 
		FROM [dbo].[fact_print] fp with(nolock)
		where eventid =@EventID
		and NewsDate >= '2025-04-01 00:00:00' 
		and NewsDate <= '2025-07-24 23:00:00'  
            AND ((Event_Type_ID = 1 AND Is_Relevant_About_Client = 1) 
                OR (--Is_Relevant_About_Client = 1 AND 
				Is_Relevant_About_Topic = 1))
)
,CTE_TEMPDATA
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
	  ,Publication,
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

	,    CASE 
        WHEN LOWER(LE.Summary) LIKE '%truck%' 
          OR LOWER(LE.Summary) LIKE '%bus%' 
          OR LOWER(LE.Summary) LIKE '%buses%' 
          OR LOWER(LE.Summary) LIKE '%tractor%' 
          OR LOWER(LE.Summary) LIKE '%cvs%' 
          OR LOWER(LE.Summary) LIKE '%commercial vehicle%' 
          OR LOWER(LE.Summary) LIKE '%commercial evs%' 
          OR LOWER(LE.Summary) LIKE '%lcv%' 
          OR LOWER(LE.Summary) LIKE '%cargo%' 
          OR LOWER(LE.Summary) LIKE '%construction%' 
          OR LOWER(LE.Summary) LIKE '%3-wheeler%' 
          OR LOWER(LE.Summary) LIKE '%baleno%'  -- Confirm if this should be 'bolero'
          OR LOWER(LE.Summary) LIKE '%veero%' 
          OR LOWER(LE.Summary) LIKE '%mahindra blazo%' 
          OR LOWER(LE.Summary) LIKE '%maxx pik up%' 
          OR LOWER(LE.Summary) LIKE '%agriculture%' 
          OR LOWER(LE.Summary) LIKE '%farm%' 
          OR LOWER(LE.Summary) LIKE '%auto-comp%' 
          OR LOWER(LE.Summary) LIKE '%auto components%' 
          OR LOWER(LE.Summary) LIKE '%last mile mobility%' 
          OR LOWER(LE.Summary) LIKE '%rickshaw%' 
          OR LOWER(LE.Summary) LIKE '%e-rickshaw%' 
        THEN 'Yes'
        ELSE 'No'
    END AS Is_Not_PV

   ,    CASE 
        WHEN LOWER(LE.Summary) LIKE '%tech mahindra%' 
          OR LOWER(LE.Summary) LIKE '%mahindra lifespaces%' 
          OR LOWER(LE.Summary) LIKE '%kotak mahindra%' 
          OR LOWER(LE.Summary) LIKE '%kotak amc%' 
          OR LOWER(LE.Summary) LIKE '%mahindra logistics%' 
          OR LOWER(LE.Summary) LIKE '%mahindra finance%' 
          OR LOWER(LE.Summary) LIKE '%mahindra armado%' 
          OR LOWER(LE.Summary) LIKE '%activa%' 
          OR LOWER(LE.Summary) LIKE '%jawa 350%' 
          OR LOWER(LE.Summary) LIKE '%hero electra%' 
          OR LOWER(LE.Summary) LIKE '%bajaj%' 
          OR LOWER(LE.Summary) LIKE '%tvs%' 
        THEN 'Yes'
        ELSE 'No'
    END AS Is_Not_Relevant_Company

	--Product mention in article

	,CASE WHEN LOWER(LE.Summary) LIKE '%xuv700%' THEN 'Yes' ELSE 'No' END AS [XUV700_In_Article]
	,CASE WHEN LOWER(LE.Summary) LIKE '%scorpio%' THEN 'Yes' ELSE 'No' END AS [Scorpio_In_Article]
	,CASE WHEN LOWER(LE.Summary) LIKE '%thar%' THEN 'Yes' ELSE 'No' END AS [Thar_In_Article]
	,CASE WHEN LOWER(LE.Summary) LIKE '%xuv 3xo%' THEN 'Yes' ELSE 'No' END AS [XUV_3XO_In_Article]
	,CASE WHEN LOWER(LE.Summary) LIKE '%be 6%' THEN 'Yes' ELSE 'No' END AS [BE_6_In_Article]
	,CASE WHEN LOWER(LE.Summary) LIKE '%xev 9e%' THEN 'Yes' ELSE 'No' END AS [XEV_9e_In_Article]
	,CASE WHEN LOWER(LE.Summary) LIKE '%bolero%' THEN 'Yes' ELSE 'No' END AS [Bolero_In_Article]

	--Product mention in Headline

	,CASE WHEN LOWER(AO.Title) LIKE '%xuv700%' THEN 'Yes' ELSE 'No' END AS [XUV700_In_Headline]
	,CASE WHEN LOWER(AO.Title) LIKE '%scorpio%' THEN 'Yes' ELSE 'No' END AS [Scorpio_In_Headline]
	,CASE WHEN LOWER(AO.Title) LIKE '%thar%' THEN 'Yes' ELSE 'No' END AS [Thar_In_Headline]
	,CASE WHEN LOWER(AO.Title) LIKE '%xuv 3xo%' THEN 'Yes' ELSE 'No' END AS [XUV_3XO_In_Headline]
	,CASE WHEN LOWER(AO.Title) LIKE '%be 6%' THEN 'Yes' ELSE 'No' END AS [BE_6_In_Headline]
	,CASE WHEN LOWER(AO.Title) LIKE '%xev 9e%' THEN 'Yes' ELSE 'No' END AS [XEV_9e_In_Headline]
	,CASE WHEN LOWER(AO.Title) LIKE '%bolero%' THEN 'Yes' ELSE 'No' END AS [Bolero_In_Headline]

	-- New: Leader name mentions in article
	,CASE WHEN LOWER(LE.Summary) LIKE '%anish shah%' THEN 'Yes' ELSE 'No' END AS [Anish_Shah_In_Article]
	,CASE WHEN LOWER(LE.Summary) LIKE '%rajesh jejurikar%' THEN 'Yes' ELSE 'No' END AS [Rajesh_Jejurikar_In_Article]
	,CASE WHEN LOWER(LE.Summary) LIKE '%nalinikanth gollagunta%' THEN 'Yes' ELSE 'No' END AS [Nalinikanth_Gollagunta_In_Article]
	,CASE 
	    WHEN LOWER(LE.Summary) LIKE '%veejay nakra%' 
	      OR LOWER(LE.Summary) LIKE '%vijay nakra%' 
	    THEN 'Yes' ELSE 'No' 
	 END AS [Veejay_or_Vijay_Nakra_In_Article]
	 ,CASE WHEN LOWER(LE.Summary) LIKE '%velusamy%' THEN 'Yes' ELSE 'No' END AS [Velusamy_In_Article]
	 ,CASE WHEN LOWER(LE.Summary) LIKE '%pratap bose%' THEN 'Yes' ELSE 'No' END AS [Pratap_Bose_In_Article]

	 -- New: Leader name mentions in Headline
	,CASE WHEN LOWER(AO.Title) LIKE '%anish shah%' THEN 'Yes' ELSE 'No' END AS [Anish_Shah_In_Headline]
	,CASE WHEN LOWER(AO.Title) LIKE '%rajesh jejurikar%' THEN 'Yes' ELSE 'No' END AS [Rajesh_Jejurikar_In_Headline]
	,CASE WHEN LOWER(AO.Title) LIKE '%nalinikanth gollagunta%' THEN 'Yes' ELSE 'No' END AS [Nalinikanth_Gollagunta_In_Headline]
	,CASE 
	    WHEN LOWER(AO.Title) LIKE '%veejay nakra%' 
	      OR LOWER(AO.Title) LIKE '%vijay nakra%' 
	    THEN 'Yes' ELSE 'No' 
	 END AS [Veejay_or_Vijay_Nakra_In_Headline]
	 ,CASE WHEN LOWER(AO.Title) LIKE '%velusamy%' THEN 'Yes' ELSE 'No' END AS [Velusamy_In_Headline]
	 ,CASE WHEN LOWER(AO.Title) LIKE '%pratap bose%' THEN 'Yes' ELSE 'No' END AS [Pratap_Bose_In_Headline]

	 -- Competitor Spokesperson in Headline
,CASE 
    WHEN LOWER(AO.Title) LIKE '%anish shah%' 
      OR LOWER(AO.Title) LIKE '%rajesh jejurikar%'
      OR LOWER(AO.Title) LIKE '%nalinikanth gollagunta%'
      OR LOWER(AO.Title) LIKE '%veejay nakra%'
      OR LOWER(AO.Title) LIKE '%vijay nakra%'
      OR LOWER(AO.Title) LIKE '%velusamy%'
      OR LOWER(AO.Title) LIKE '%pratap bose%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_Mahindra]

,CASE 
    WHEN LOWER(AO.Title) LIKE '%rc bhargava%' 
      OR LOWER(AO.Title) LIKE '%c. bhargava%'
      OR LOWER(AO.Title) LIKE '%hisashi takeuchi%'
      OR LOWER(AO.Title) LIKE '%partho banerjee%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_Maruti_Suzuki]

,CASE 
    WHEN LOWER(AO.Title) LIKE '%rajeev chaba%' 
      OR LOWER(AO.Title) LIKE '%satinder singh bajwa%'
      OR LOWER(AO.Title) LIKE '%satinder bajwa%'
      OR LOWER(AO.Title) LIKE '%gaurav gupta%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_MG]

,CASE 
    WHEN LOWER(AO.Title) LIKE '%girish arun wagh%' 
      OR LOWER(AO.Title) LIKE '%vivek srivatsa%'
      OR LOWER(AO.Title) LIKE '%shailesh chandra%'
      OR LOWER(AO.Title) LIKE '%natarajan chandrasekaran%'
      OR LOWER(AO.Title) LIKE '%n chandrasekaran%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_Tata_Motors]

,CASE 
    WHEN LOWER(AO.Title) LIKE '%tarun garg%' 
      OR LOWER(AO.Title) LIKE '%gopala krishnan%'
      OR LOWER(AO.Title) LIKE '%puneet anand%'
      OR LOWER(AO.Title) LIKE '%virat khullar%'
      OR LOWER(AO.Title) LIKE '%unsoo kim%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_Hyundai_India]

,CASE 
    WHEN LOWER(AO.Title) LIKE '%gwanggu lee%' 
      OR LOWER(AO.Title) LIKE '%hardeep singh brar%'
      OR LOWER(AO.Title) LIKE '%hardeep brar%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_Kia_India]



			
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
			WHERE e.EventID=@EventID AND AO.NewsDate >= '2025-04-01 00:00:00' AND AO.NewsDate <= '2025-07-24 23:00:00'
			AND (
				(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(--LED.Is_Relevant_About_Client = 1 AND 
				LED.Is_Relevant_About_Topic = 1)
			)
			
)
			,CTE_#Temp_Tags AS
(
			
select  ROW_NUMBER() over(partition by TLPMEID order by TLPMEID  ) as RN,*  from [dbo].Tag_MGMotor_21072025_Print where TLPMEID in (select TLPMEID from CTE_TEMPDATA)
			)


			select  
			article_id,incident_id,a.url,
			title,description,date_time,
			 author,
			edition,
			sentiment,
			a.publication_name, publication_type,
			publication_circulation,
			pi_score,
			ave
			,date_sort,circulation_sort,ave_sort, mention_type,
			 is_bookmarked
			,headline_sentiment,pi_score_sort
			,ArticleType
			,DiscourseCategory
			,a.TLPMEID
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
	  ,Classifier_IsCompetitorSpokespersonMentioned	
	  ,Classifier_IsNotRelevantDomain
      ,[LPID]
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
[XUV700_In_Article],
[Scorpio_In_Article],
[Thar_In_Article],
[XUV_3XO_In_Article],
[BE_6_In_Article],
[XEV_9e_In_Article],
[Bolero_In_Article],
[XUV700_In_Headline],
[Scorpio_In_Headline],
[Thar_In_Headline],
[XUV_3XO_In_Headline],
[BE_6_In_Headline],
[XEV_9e_In_Headline],
[Bolero_In_Headline],
[Anish_Shah_In_Article],
[Rajesh_Jejurikar_In_Article],
[Nalinikanth_Gollagunta_In_Article],
[Veejay_or_Vijay_Nakra_In_Article],
[Velusamy_In_Article],
[Pratap_Bose_In_Article],
[Anish_Shah_In_Headline],
[Rajesh_Jejurikar_In_Headline],
[Nalinikanth_Gollagunta_In_Headline],
[Veejay_or_Vijay_Nakra_In_Headline],
[Velusamy_In_Headline],
[Pratap_Bose_In_Headline]
,[Competitor_spokesperson_in_headline_Mahindra]
,[Competitor_spokesperson_in_headline_Maruti_Suzuki]
,[Competitor_spokesperson_in_headline_MG]
,[Competitor_spokesperson_in_headline_Tata_Motors]
,[Competitor_spokesperson_in_headline_Hyundai_India]
,[Competitor_spokesperson_in_headline_Kia_India]

       from CTE_TEMPDATA a with(nolock)
			left JOIN CTE_#Temp_Tags th with(nolock) on th.TLPMEID=a.TLPMEID and RN=1
			


--select * from Event where EventID in (153,154,155,156,157,158)