
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
      ,[LOID]
      ,[TLOMEID]
      ,[Publication] 
	  INTO Tag_MGMotor_21072025_Online
	  from LinkOnlineTagged_MGMotor_24July a
	  INNER JOIN [dbo].[TagLinkOnlineMap] TLOM with(nolock) on TLOM.TLOMID=a.article_ID
	  INNER JOIN [dbo].[TagLinkOnlineMapE] TLOME with(nolock) on TLOME.TLOMID=tlom.TLOMID

--	  --select *from Tag_MGMotor_21072025_shiv


--	  --select *from Tag_Hyundai_21072025
----drop table Tag_KiaMotor_21072025_shiv

----select * into Tag_Hyundai_21072025_Shiv from Tag_Hyundai_21072025

--select * into Tag_KiaMotor_21072025_print from Tag_hyundai_21072025_print
--select * from Tag_Hyundai_21072025_print


