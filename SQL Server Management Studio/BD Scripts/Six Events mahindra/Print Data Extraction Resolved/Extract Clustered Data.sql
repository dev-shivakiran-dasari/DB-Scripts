




;with CTE_TEMPDATA
AS
(select distinct article_id,incident_id,url,
			title,description,date_time,
			author,
			edition,
			sentiment,
			publication_name,publication_icon,publication_type,publication_category,
			publication_circulation,
			pi_score,
			ave
			,date_sort,circulation_sort,ave_sort,mention_type,
			is_bookmarked
			,headline_sentiment,pi_score_sort
			,ArticleType
			,DiscourseCategory
			,TLPMEID
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
	  ,Publication,
	  --JSON_VALUE(dynamic_prompt_output, '$."Product & Brand"') AS [Is_Product_Brand],
   -- JSON_VALUE(dynamic_prompt_output, '$."Leadership & Corporate"') AS [Is_Leadership_Corporate],
   -- JSON_VALUE(dynamic_prompt_output, '$."Financials"') AS [Is_Financials],
   -- JSON_VALUE(dynamic_prompt_output, '$."Manufacturing & Operations"') AS [Is_Manufacturing_Operations],
   -- JSON_VALUE(dynamic_prompt_output, '$."Consumer-Facing Initiatives"') AS [Is_ConsumerFacing_Initiatives],
   -- JSON_VALUE(dynamic_prompt_output, '$."Legal / Compliance"') AS [Is_Legal_Compliance],
   -- JSON_VALUE(dynamic_prompt_output, '$."Consumer Education & Marketing Content"') AS [Is_Consumer_Education_Marketing_Content],
   -- JSON_VALUE(dynamic_prompt_output, '$."Policy & Regulation"') AS [Is_Policy_Regulation],
   -- JSON_VALUE(dynamic_prompt_output, '$."Sector-Level & Market Trends"') AS [Is_SectorLevel_MarketTrends],
   -- JSON_VALUE(dynamic_prompt_output, '$."Technology Innovation"') AS [Is_Technology_Innovation],
   -- JSON_VALUE(dynamic_prompt_output, '$."Electronic or hybrid vehicles"') AS [Is_Electronic_Hybridvehicles],
   -- JSON_VALUE(dynamic_prompt_output, '$."Supply Chain / Vendor Ecosystem"') AS [Is_SupplyChain_VendorEcosystem],
   -- JSON_VALUE(dynamic_prompt_output, '$."Others"') AS [Is_Others],
   -- JSON_VALUE(dynamic_prompt_output, '$."Sub Category"') AS [Sub_Category],

	   CASE 
        WHEN LOWER(Summary) LIKE '%truck%' 
          OR LOWER(Summary) LIKE '%bus%' 
          OR LOWER(Summary) LIKE '%buses%' 
          OR LOWER(Summary) LIKE '%tractor%' 
          OR LOWER(Summary) LIKE '%cvs%' 
          OR LOWER(Summary) LIKE '%commercial vehicle%' 
          OR LOWER(Summary) LIKE '%commercial evs%' 
          OR LOWER(Summary) LIKE '%lcv%' 
          OR LOWER(Summary) LIKE '%cargo%' 
          OR LOWER(Summary) LIKE '%construction%' 
          OR LOWER(Summary) LIKE '%3-wheeler%' 
          OR LOWER(Summary) LIKE '%baleno%'  -- Confirm if this should be 'bolero'
          OR LOWER(Summary) LIKE '%veero%' 
          OR LOWER(Summary) LIKE '%mahindra blazo%' 
          OR LOWER(Summary) LIKE '%maxx pik up%' 
          OR LOWER(Summary) LIKE '%agriculture%' 
          OR LOWER(Summary) LIKE '%farm%' 
          OR LOWER(Summary) LIKE '%auto-comp%' 
          OR LOWER(Summary) LIKE '%auto components%' 
          OR LOWER(Summary) LIKE '%last mile mobility%' 
          OR LOWER(Summary) LIKE '%rickshaw%' 
          OR LOWER(Summary) LIKE '%e-rickshaw%' 
        THEN 'Yes'
        ELSE 'No'
    END AS Is_Not_PV

   ,    CASE 
        WHEN LOWER(Summary) LIKE '%tech mahindra%' 
          OR LOWER(Summary) LIKE '%mahindra lifespaces%' 
          OR LOWER(Summary) LIKE '%kotak mahindra%' 
          OR LOWER(Summary) LIKE '%kotak amc%' 
          OR LOWER(Summary) LIKE '%mahindra logistics%' 
          OR LOWER(Summary) LIKE '%mahindra finance%' 
          OR LOWER(Summary) LIKE '%mahindra armado%' 
          OR LOWER(Summary) LIKE '%activa%' 
          OR LOWER(Summary) LIKE '%jawa 350%' 
          OR LOWER(Summary) LIKE '%hero electra%' 
          OR LOWER(Summary) LIKE '%bajaj%' 
          OR LOWER(Summary) LIKE '%tvs%' 
        THEN 'Yes'
        ELSE 'No'
    END AS Is_Not_Relevant_Company

	--Product mention in article

	,CASE WHEN LOWER(Summary) LIKE '%xuv700%' THEN 'Yes' ELSE 'No' END AS [XUV700_In_Article]
	,CASE WHEN LOWER(Summary) LIKE '%scorpio%' THEN 'Yes' ELSE 'No' END AS [Scorpio_In_Article]
	,CASE WHEN LOWER(Summary) LIKE '%thar%' THEN 'Yes' ELSE 'No' END AS [Thar_In_Article]
	,CASE WHEN LOWER(Summary) LIKE '%xuv 3xo%' THEN 'Yes' ELSE 'No' END AS [XUV_3XO_In_Article]
	,CASE WHEN LOWER(Summary) LIKE '%be 6%' THEN 'Yes' ELSE 'No' END AS [BE_6_In_Article]
	,CASE WHEN LOWER(Summary) LIKE '%xev 9e%' THEN 'Yes' ELSE 'No' END AS [XEV_9e_In_Article]
	,CASE WHEN LOWER(Summary) LIKE '%bolero%' THEN 'Yes' ELSE 'No' END AS [Bolero_In_Article]

	--Product mention in Headline

	,CASE WHEN LOWER(Title) LIKE '%xuv700%' THEN 'Yes' ELSE 'No' END AS [XUV700_In_Headline]
	,CASE WHEN LOWER(Title) LIKE '%scorpio%' THEN 'Yes' ELSE 'No' END AS [Scorpio_In_Headline]
	,CASE WHEN LOWER(Title) LIKE '%thar%' THEN 'Yes' ELSE 'No' END AS [Thar_In_Headline]
	,CASE WHEN LOWER(Title) LIKE '%xuv 3xo%' THEN 'Yes' ELSE 'No' END AS [XUV_3XO_In_Headline]
	,CASE WHEN LOWER(Title) LIKE '%be 6%' THEN 'Yes' ELSE 'No' END AS [BE_6_In_Headline]
	,CASE WHEN LOWER(Title) LIKE '%xev 9e%' THEN 'Yes' ELSE 'No' END AS [XEV_9e_In_Headline]
	,CASE WHEN LOWER(Title) LIKE '%bolero%' THEN 'Yes' ELSE 'No' END AS [Bolero_In_Headline]

	-- New: Leader name mentions in article
	,CASE WHEN LOWER(Summary) LIKE '%anish shah%' THEN 'Yes' ELSE 'No' END AS [Anish_Shah_In_Article]
	,CASE WHEN LOWER(Summary) LIKE '%rajesh jejurikar%' THEN 'Yes' ELSE 'No' END AS [Rajesh_Jejurikar_In_Article]
	,CASE WHEN LOWER(Summary) LIKE '%nalinikanth gollagunta%' THEN 'Yes' ELSE 'No' END AS [Nalinikanth_Gollagunta_In_Article]
	,CASE 
	    WHEN LOWER(Summary) LIKE '%veejay nakra%' 
	      OR LOWER(Summary) LIKE '%vijay nakra%' 
	    THEN 'Yes' ELSE 'No' 
	 END AS [Veejay_or_Vijay_Nakra_In_Article]
	 ,CASE WHEN LOWER(Summary) LIKE '%velusamy%' THEN 'Yes' ELSE 'No' END AS [Velusamy_In_Article]
	 ,CASE WHEN LOWER(Summary) LIKE '%pratap bose%' THEN 'Yes' ELSE 'No' END AS [Pratap_Bose_In_Article]

	 -- New: Leader name mentions in Headline
	,CASE WHEN LOWER(Title) LIKE '%anish shah%' THEN 'Yes' ELSE 'No' END AS [Anish_Shah_In_Headline]
	,CASE WHEN LOWER(Title) LIKE '%rajesh jejurikar%' THEN 'Yes' ELSE 'No' END AS [Rajesh_Jejurikar_In_Headline]
	,CASE WHEN LOWER(Title) LIKE '%nalinikanth gollagunta%' THEN 'Yes' ELSE 'No' END AS [Nalinikanth_Gollagunta_In_Headline]
	,CASE 
	    WHEN LOWER(Title) LIKE '%veejay nakra%' 
	      OR LOWER(Title) LIKE '%vijay nakra%' 
	    THEN 'Yes' ELSE 'No' 
	 END AS [Veejay_or_Vijay_Nakra_In_Headline]
	 ,CASE WHEN LOWER(Title) LIKE '%velusamy%' THEN 'Yes' ELSE 'No' END AS [Velusamy_In_Headline]
	 ,CASE WHEN LOWER(Title) LIKE '%pratap bose%' THEN 'Yes' ELSE 'No' END AS [Pratap_Bose_In_Headline]

	 -- Competitor Spokesperson in Headline
,CASE 
    WHEN LOWER(Title) LIKE '%anish shah%' 
      OR LOWER(Title) LIKE '%rajesh jejurikar%'
      OR LOWER(Title) LIKE '%nalinikanth gollagunta%'
      OR LOWER(Title) LIKE '%veejay nakra%'
      OR LOWER(Title) LIKE '%vijay nakra%'
      OR LOWER(Title) LIKE '%velusamy%'
      OR LOWER(Title) LIKE '%pratap bose%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_Mahindra]

,CASE 
    WHEN LOWER(Title) LIKE '%rc bhargava%' 
      OR LOWER(Title) LIKE '%c. bhargava%'
      OR LOWER(Title) LIKE '%hisashi takeuchi%'
      OR LOWER(Title) LIKE '%partho banerjee%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_Maruti_Suzuki]

,CASE 
    WHEN LOWER(Title) LIKE '%rajeev chaba%' 
      OR LOWER(Title) LIKE '%satinder singh bajwa%'
      OR LOWER(Title) LIKE '%satinder bajwa%'
      OR LOWER(Title) LIKE '%gaurav gupta%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_MG]

,CASE 
    WHEN LOWER(Title) LIKE '%girish arun wagh%' 
      OR LOWER(Title) LIKE '%vivek srivatsa%'
      OR LOWER(Title) LIKE '%shailesh chandra%'
      OR LOWER(Title) LIKE '%natarajan chandrasekaran%'
      OR LOWER(Title) LIKE '%n chandrasekaran%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_Tata_Motors]

,CASE 
    WHEN LOWER(Title) LIKE '%tarun garg%' 
      OR LOWER(Title) LIKE '%gopala krishnan%'
      OR LOWER(Title) LIKE '%puneet anand%'
      OR LOWER(Title) LIKE '%virat khullar%'
      OR LOWER(Title) LIKE '%unsoo kim%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_Hyundai_India]

,CASE 
    WHEN LOWER(Title) LIKE '%gwanggu lee%' 
      OR LOWER(Title) LIKE '%hardeep singh brar%'
      OR LOWER(Title) LIKE '%hardeep brar%'
    THEN 'Yes' ELSE 'No' 
END AS [Competitor_spokesperson_in_headline_Kia_India]



			from Shiv_LinkPrintTagged_TataMotors_01Sep
			
)
			,CTE_#Temp_Tags AS
(
			
select  ROW_NUMBER() over(partition by article_id order by article_id  ) as RN,*  from [dbo].LinkPrintTagged_TataMotors_01Sep where article_id in (select article_id from CTE_TEMPDATA)
			)


			select  
			a.article_id,a.incident_id,a.url,
			a.title,a.description,a.date_time,
			 a.author,
			a.edition,
			a.sentiment,
			a.publication_name, a.publication_type,
			a.publication_circulation,
			a.pi_score,
			a.ave
			,a.date_sort,a.circulation_sort,a.ave_sort, a.mention_type,
			 a.is_bookmarked
			,a.headline_sentiment,a.pi_score_sort
			,ArticleType
			,DiscourseCategory
			,a.TLPMEID
      ,[Classifier_StockNews]
      ,[Classifier_AlsoRead]
      ,[Classifier_Reach_LessThan500]
      ,[Classifier_Reach_MoreThan10000]
      ,[Classifier_URL_ContentType]
      ,[Classifier_TradeMedia]
--      ,[Classifier_Client]
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
      --,[LPID]
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
	  --,ISNULL([Is_Product_Brand],'NO') as [Is_Product_Brand]
   --   ,ISNULL([Is_Leadership_Corporate],'NO') as [Is_Leadership_Corporate]
   --   ,ISNULL([Is_Financials],'NO') as [Is_Financials]
   --   ,ISNULL([Is_Manufacturing_Operations],'NO')as [Is_Manufacturing_Operations]
   --   ,ISNULL([Is_ConsumerFacing_Initiatives],'NO') as [Is_ConsumerFacing_Initiatives]
   --   ,ISNULL([Is_Legal_Compliance],'NO') as [Is_Legal_Compliance]
   --   ,ISNULL([Is_Consumer_Education_Marketing_Content],'NO') as [Is_Consumer_Education_Marketing_Content]
   --   ,ISNULL([Is_Policy_Regulation],'NO') as [Is_Policy_Regulation]
   --   ,ISNULL([Is_SectorLevel_MarketTrends],'NO') as [Is_SectorLevel_MarketTrends]
   --   ,ISNULL([Is_Technology_Innovation],'NO') as [Is_Technology_Innovation]
   --   ,ISNULL([Is_Electronic_Hybridvehicles],'NO') as [Is_Electronic_Hybridvehicles]
   --   ,ISNULL([Is_SupplyChain_VendorEcosystem],'NO') as [Is_SupplyChain_VendorEcosystem]
   --   ,ISNULL([Is_Others],'NO') as [Is_Others]
   --   ,ISNULL([Sub_Category],'NO') as [Sub_Category]
	  ,ISNULL(Is_Not_PV,'NO') as Is_Not_PV, 
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
			left JOIN CTE_#Temp_Tags th with(nolock) on th.article_id=a.article_id and RN=1
			


--select * from Event where EventID in (153,154,155,156,157,158)