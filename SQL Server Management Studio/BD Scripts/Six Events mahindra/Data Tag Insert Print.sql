
----select * from tags_hyundai

select TLOME.[TagID]
      ,[url]
      ,[Classifier_StockNews]
      ,[Classifier_AlsoRead]
      ,[Classifier_Reach_LessThan500]
      ,[Classifier_Reach_MoreThan10000]
      ,[Classifier_URL_ContentType]
      ,[Classifier_TradeMedia]
      ,[Classifier_Client_MGMotor] as [Classifier_Client]
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
      --,[Classifier_IsNonNews]
      ,[LPID]
      ,[TLPMEID]
      ,[Publication_name] 
	  INTO Tag_MGMotor_21072025_Print
	  from LinkPrintTagged_MGMotor_24July a
	  INNER JOIN [dbo].[TagLinkPrintMap] TLOM with(nolock) on TLOM.TLPMID=a.article_ID
	  INNER JOIN [dbo].[TagLinkPrintMapE] TLOME with(nolock) on TLOME.TLPMID=tlom.TLPMID
