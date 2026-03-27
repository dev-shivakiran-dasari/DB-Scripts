



		select tlom.TLOMID as article_id,e.EventID as incident_id,AO.Url as url,
		isnull(Isnull(left(LP.Title,100),isnull(left(LP.Title,100),NULL)),'') as title
		,LE.Summary as description,
		LP.Date as date_time,isnull(MLOA.AuthorName,'NA') as author,replace(isnull(LED.Sentiment,'Neutral'),'None','Neutral') as sentiment,
		p.Publication as publication_url,'https://www.google.com/s2/favicons?domain='+p.Publication as publication_icon,
		isnull(p.PublicationCategory,'NA') as publication_category,
		isnull(p.Type,'NA') as publication_type,
		isnull(p.DA,0) as publication_da,isnull(p.TotalVisits,0) as publication_traffic,
		'' AS ArticleType,
		replace(isnull(LED.headline_sentiments,'Neutral'),'None','Neutral') as headline_sentiments,
		CASE	
			WHEN client_name_in_headline=1 THEN 'True'
			ELSE 'False'
		END as client_name_in_headline,TLOME.TLOMEID
		INTO Temp_BaseDate_ToDate_Online_Shiv
		FROM dbo.LinkOnline AO with (nolock)
		INNER JOIN [dbo].[LinkOnline_Processed] LP WITH (NOLOCK) ON LP.LOPID=AO.LOPID
		LEFT JOIN [dbo].mstLinkOnlineAuthor MLOA WITH (NOLOCK) ON MLOA.AuthorID=AO.AuthorID
		INNER JOIN [dbo].mstPublication P WITH (NOLOCK) ON p.PublicationID = AO.PublicationID
		INNER JOIN [dbo].[TagLinkOnlineMap] tlom WITH (NOLOCK) ON tlom.LOID=AO.LOID INNER JOIN [dbo].[TagLinkOnlineMapE] TLOME with(nolock) on TLOME.TLOMID=tlom.TLOMID
		INNER JOIN [dbo].[LinkOnline_Enriched] LE with (nolock) ON LE.LOID = AO.LOID
		INNER JOIN [dbo].[LinkOnline_EnrichedDetail] LED with (nolock) ON LED.TLOMEID = TLOME.TLOMEID
		INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
		WHERE e.EventID=957 AND LP.Date >= '2025-04-22 00:00:00' AND LP.Date <= '2025-04-29 12:35:05' 
		AND (
				(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
			)



--drop table Temp_BaseDate_ToDate_Online_Shiv


select distinct tlom.TLPMID as article_id,e.EventID as incident_id,'http://print.adfactorspr.com/NewsDetailsPublished.aspx?NewsID='+AO.Url as url,
		AO.Title as title,LE.Summary as description,REPLACE(CONVERT(NVARCHAR,AO.NewsDate, 106), ' ', '-') as date_time,
		case 
			WHEN MLPA.Agency IS NOT NULL THEN MLPA.Agency
			WHEN AO.Source IS NOT NULL THEN AO.Source
			WHEN MLPJ.JournalistName IS NOT NULL THEN MLPJ.JournalistName
		END	  as author,
		stuff((SELECT ',' + LinkPrint_Image.PageNo 
				FROM LinkPrint_Image 
				WHERE LinkPrint_Image.LPID = AO.LPID
				FOR XML PATH('')),1,1,'') AS page_no,
		stuff((SELECT ',' + mstLinkPrintEdition.Edition 
				FROM LinkPrint_Edition 
				INNER JOIN mstLinkPrintEdition with (nolock) ON  mstLinkPrintEdition.EditionID = LinkPrint_Edition.EditionID
				WHERE LinkPrint_Edition.LPID = AO.LPID
				FOR XML PATH('')),1,1,'') AS edition,
		LED.Sentiment as sentiment,
		p.Publication as publication_name,'' as publication_icon,isnull(p.Type,'NA') as publication_type,'' as publication_category,
		isnull(AO.circulationscore,0) as publication_circulation,isnull(AO.AVE,0) as ave,
		'' AS ArticleType,isnull(headline_sentiments,'Neutral') as headline_sentiments,
		CASE	
			WHEN client_name_in_headline=1 THEN 'True'
			ELSE 'False'
		END as client_name_in_headline,
		tlome.TLPMEID
		into Temp_BaseDate_ToDate_Print_Shiv
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
		WHERE e.EventID=957 AND AO.NewsDate >= '2025-04-22 00:00:00' AND AO.NewsDate <= '2025-04-29 12:35:05'  
		AND (
				(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
			)
		

--drop table Temp_BaseDate_ToDate_Print_Shiv




select tlom.TLTMID,EventID,TonalityID,Sentiment,t.tweet_id,t.LTID,t.THID,Tweet_Date into #TwitterTemp from LinkTweet t with (nolock) 
		INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID 
		INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
		INNER JOIN [dbo].[LinkTweet_Enriched] LE with (nolock) ON LE.LTID = t.LTID
		INNER JOIN [dbo].[LinkTweet_EnrichedDetail] LED with (nolock) ON LED.TLTMEID = TLOME.TLTMEID AND led.Is_Relevant_About_Topic=1
		INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID AND e.EventID=957
		where t.Tweet_Date >= '2025-04-22 00:00:00'  AND t.Tweet_Date <= '2025-04-29 12:35:05' 


		--CREATE TEMP TABLES START--
		select t.TLTMID as twitter_id,t.tweet_id as tweet_id,957 as incident_id,
		t.Tweet_Date as date_time,Sentiment as sentiment,tweet_conversationid,
		profile_handle,profile_name,profile_followerscount,profile_profilepicurl,
		engagement_retweetcount,engagement_replycount,engagement_likecount,engagement_quotecount,engagement_bookmarkcount,engagement_viewcount,
		engagement_retweetcount+engagement_replycount+engagement_likecount+engagement_quotecount as engagement_total,tonality,
		Profile_Category as UserProfileCategory,t.THID,t.LTID
		into Temp_BaseDate_ToDate_Twitter_Shiv
		FROM #TwitterTemp t with (nolock) 
		inner join LinkTweet_Detail ld with (nolock) on ld.LTID = t.LTID AND ld.Tweet_IsRetweeted = 0
		inner join TwitterHandle th with (nolock) on th.THID = t.THID
		inner join LinkTweet_Engagement LTE with (nolock) on LTE.LTID = t.LTID
		--INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
		--INNER JOIN [dbo].[LinkTweet_Enriched] LE with (nolock) ON LE.LTID = t.LTID
		--INNER JOIN [dbo].[LinkTweet_EnrichedDetail] LED with (nolock) ON LED.TLTMID = t.TLTMID AND led.Is_Relevant_About_Topic=1
		INNER JOIN [dbo].mstTonality_Enriched ME with (nolock) ON ME.TonalityID = t.TonalityID
		--INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID AND e.EventID=@TopicID

		drop table #TwitterTemp


		--drop table Temp_BaseDate_ToDate_Twitter_Shiv

select  tlom.TLTMID as twitter_id,t.Tweet_ID as Tweet_ID,e.EventID as incident_id,th.THID,
		NULL as url,NULL as description,
		t.Tweet_Date as date_time,LED.Sentiment as sentiment,tweet_conversationid,
		profile_handle,profile_name,profile_followerscount,profile_followingcount,profile_tweetscount,profile_listscount,profile_isprotected,
		profile_isverified,profile_verifiedtype,
		NULL as profile_profilepicurl,
		NULL as profile_externalUrl,
		NULL as profile_description,
		NULL as profile_location,
		engagement_retweetcount,engagement_replycount,engagement_likecount,engagement_quotecount,engagement_bookmarkcount,engagement_viewcount,
		engagement_retweetcount+engagement_replycount+engagement_likecount+engagement_quotecount as engagement_total,
		tonality,
		NULL as Mentioned_Hashtags,
		NULL as Mentioned_Handles,
		NULL as Mentioned_Hyperlinks,Profile_Category as UserProfileCategory,UpdatedConversationID
		into Temp_BaseDate_ToDate_Twitter_Stats_Shiv
		FROM [dbo].LinkTweet t with (nolock)
		inner join LinkTweet_Detail ld with (nolock) on ld.LTID = t.LTID
		inner join TwitterHandle th with (nolock) on th.THID = t.THID
		inner join LinkTweet_Engagement LTE with (nolock) on LTE.LTID = t.LTID
		INNER JOIN [dbo].[TagLinkTweetMap] tlom WITH (NOLOCK) ON tlom.LTID=t.LTID INNER JOIN [dbo].[TagLinkTweetMapE] tlome WITH (NOLOCK) ON TLOME.TLTMID=tlom.TLTMID
		INNER JOIN [dbo].[LinkTweet_Enriched] LE with (nolock) ON LE.LTID = t.LTID
		INNER JOIN [dbo].[LinkTweet_EnrichedDetail] LED with (nolock) ON LED.TLTMEID = TLOME.TLTMEID
		INNER JOIN [dbo].mstTonality_Enriched ME with (nolock) ON ME.TonalityID = LED.TonalityID
		INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID  AND e.EventID=957
		where t.Tweet_Date >= '2025-04-22 00:00:00'  AND t.Tweet_Date <= '2025-04-29 12:35:05' 
		AND ld.Tweet_IsRetweeted = 0 AND led.Is_Relevant_About_Topic=1


		--drop table Temp_BaseDate_ToDate_Twitter_Stats_Shiv




		select distinct tlom.TLPMID as article_id,e.EventID as incident_id,
		'' as url,
		'' title,'' as description,REPLACE(CONVERT(NVARCHAR,AO.NewsDate, 106), ' ', '-') as date_time,
		case 
			WHEN MLPA.Agency IS NOT NULL THEN MLPA.Agency
			WHEN AO.Source IS NOT NULL THEN AO.Source
			WHEN MLPJ.JournalistName IS NOT NULL THEN MLPJ.JournalistName
		END	  as author,'' as page_no,
		stuff((SELECT mstLinkPrintEdition.Edition + ','
				FROM LinkPrint_Edition 
				INNER JOIN mstLinkPrintEdition with (nolock) ON  mstLinkPrintEdition.EditionID = LinkPrint_Edition.EditionID
				WHERE LinkPrint_Edition.LPID = AO.LPID
				FOR XML PATH('')),1,1,'') AS edition,'' as sentiment,
		isnull(p.Publication,'NA') as publication_name,'' as publication_icon,'' as publication_type,'' as publication_category,
		isnull(circulationscore,0) as publication_circulation,isnull(AVE,0) as ave
		,'' as headline_sentiments,isnull(client_name_in_headline,0) as client_name_in_headline
		into Temp_BaseDate_ToDate_Print_Stats_Shiv
		FROM dbo.LinkPrint AO with (nolock)
		INNER JOIN [dbo].mstPublication P WITH (NOLOCK) ON p.PublicationID = AO.PublicationID
		LEFT JOIN [dbo].mstLinkPrintAgency MLPA WITH (NOLOCK) ON MLPA.AgencyID=AO.AgencyID
		LEFT JOIN LinkPrint_Journalist LPJ WITH(NOLOCK) ON AO.LPID=LPJ.LPID
		LEFT JOIN mstLinkPrintJournalist MLPJ WITH(NOLOCK) ON MLPJ.JournalistID=LPJ.JournalistID
		INNER JOIN [dbo].[TagLinkPrintMap] tlom WITH (NOLOCK) ON tlom.LPID=AO.LPID 
		INNER JOIN [dbo].[TagLinkPrintMapE] tlome WITH (NOLOCK) ON TLOME.TLPMID=tlom.TLPMID
		INNER JOIN [dbo].[LinkPrint_Enriched] LE with (nolock) ON LE.LPID = AO.LPID
		INNER JOIN [dbo].LinkPrint_Enriched_ArticleType LEA with (nolock) ON LEA.LPEID = LE.LPEID
		INNER JOIN [dbo].mstArticleType_Enriched ME with (nolock) ON ME.ArticleTypeID = LEA.ArticleTypeID
		INNER JOIN [dbo].[LinkPrint_EnrichedDetail] LED with (nolock) ON LED.TLPMEID = TLOME.TLPMEID
		INNER JOIN [dbo].[Event] e WITH (NOLOCK) ON e.TagID=TLOME.TagID
		WHERE e.EventID=957 AND AO.NewsDate >= '2025-04-22 00:00:00' AND AO.NewsDate <= '2025-04-29 12:35:05'  
		AND (
			(e.EventTypeID=1 AND LED.Is_Relevant_About_Client = 1) 	OR 	(LED.Is_Relevant_About_Client = 1 AND LED.Is_Relevant_About_Topic = 1)
		)

		--drop table Temp_BaseDate_ToDate_Print_Stats_Shiv