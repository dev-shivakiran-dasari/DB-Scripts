CREATE TABLE [dbo].[UserMarkedIrrelevantList](
	[UMILID] [int] Primary key IDENTITY(1,1) NOT NULL,
	[RecordID] [int] NULL,
	[RefID] [int] NULL,
	[PlatformID] [int] NULL,
	[UserID] [int] NULL,
	[Reason] [nvarchar](1000) NULL,
	[IsRestored] [int] NULL default 0,
	[CreatedAt] [datetime] default getdate() NULL,
	[ModifiedAt] [datetime] NULL)


GO
/****** Object:  StoredProcedure [dbo].[USP_UserMarkedIrrelevantList_Fetch]    Script Date: 24-09-2025 12:16:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[USP_UserMarkedIrrelevantList_Fetch]
@UserID INT=0,
@IncidentID INT=0,
@PlatformID INT=0
AS
BEGIN
	IF(@PlatformID=1)
	BEGIN
		select RecordID as article_id ,a.RefID as incident_id ,PlatformID as platform_id ,a.UserID as [user_id] ,Reason as reason ,IsRestored as is_restored,url,
		title,date_time,author,publication ,sentiment,u.Name as marked_by,a.CreatedAt as marked_at,'https://www.google.com/s2/favicons?domain='+Publication as publication_icon
		from UserMarkedIrrelevantList a WITH(NOLOCK) 
		INNER JOIN fact_online b WITH(NOLOCK)  on a.RecordID=b.tlom_id and event_id=@IncidentID
		LEFT JOIN [USER] u with(NOLOCK) on a.UserID=u.UserID
		where a.RefID=@IncidentID  and PlatformID=@PlatformID and IsRestored=0
		and (a.CreatedAt>=GETDATE()-7 OR a.ModifiedAt>=GETDATE()-7)
		Order by a.createdAt desc
	END
	ELSE IF(@PlatformID=2)
	BEGIN
		select RecordID as article_id ,a.RefID as incident_id ,PlatformID as platform_id ,a.UserID as [user_id] ,Reason as reason ,IsRestored as is_restored,url
		,title,newsdate as date_time,author,publication ,sentiment,u.Name as marked_by ,a.CreatedAt as marked_at,'' as publication_icon
		from UserMarkedIrrelevantList a WITH(NOLOCK) 
		INNER JOIN fact_print b WITH(NOLOCK)  on a.RecordID=b.tlpmid and eventid=@IncidentID
		LEFT JOIN [USER] u with(NOLOCK) on a.UserID=u.UserID
		where a.RefID=@IncidentID  and PlatformID=@PlatformID and IsRestored=0
		and (a.CreatedAt>=GETDATE()-7 OR a.ModifiedAt>=GETDATE()-7)
		Order by a.createdAt desc
	END
	ELSE IF(@PlatformID=3)
	BEGIN
		select RecordID as article_id ,a.RefID as incident_id ,PlatformID as platform_id ,a.UserID as [user_id] ,Reason as reason ,IsRestored as is_restored,c.Tweet_URL as url,
		Tweet_Text as title,b.tweet_date as date_time,profile_name as author,profile_handle as publication ,sentiment ,u.Name as marked_by ,a.CreatedAt as marked_at,
		profile_profile_pic_url as publication_icon
		from UserMarkedIrrelevantList a WITH(NOLOCK) 
		INNER JOIN fact_twitter b WITH(NOLOCK)  on a.RecordID=b.tltm_id and event_id=@IncidentID
		INNER JOIN LinkTweet c WITH(NOLOCK)  on c.LTID=b.LT_ID
		LEFT JOIN [USER] u with(NOLOCK) on a.UserID=u.UserID
		where a.RefID=@IncidentID  and PlatformID=@PlatformID and IsRestored=0
		and (a.CreatedAt>=GETDATE()-7 OR a.ModifiedAt>=GETDATE()-7)
		Order by a.createdAt desc
	END
	ELSE IF(@PlatformID=4)
	BEGIN
		select RecordID as article_id ,a.RefID as incident_id ,PlatformID as platform_id ,a.UserID as [user_id] ,Reason as reason ,IsRestored as is_restored,
		Video_URL as url,Video_Title as title,Video_Date as date_time,yc.Channel_Name as author,yc.Channel_Handle as publication ,sentiment ,u.Name as marked_by ,a.CreatedAt as marked_at,
		yc.Channel_ProfileImageLink as publication_icon
		from UserMarkedIrrelevantList a WITH(NOLOCK) 
		INNER JOIN  dbo.TagLinkYouTubeMapE AS tlyme WITH(NOLOCK)  on a.RecordID=tlyme.tlymid
		INNER JOIN  dbo.TagLinkYouTubeMap AS tlym WITH (NOLOCK) ON tlym.tlymid = tlyme.tlymid 
		INNER JOIN  dbo.[LinkYouTube] AS y WITH (NOLOCK) ON y.LYID= tlym.LYID
		INNER JOIN [dbo].[YouTubeChannel] yc WITH (NOLOCK) ON yc.YCID = y.YCID
		INNER JOIN [dbo].[LinkYouTube_EnrichedDetail] LED WITH (NOLOCK) ON LED.TLYMEID = tlyme.TLYMEID
		LEFT JOIN [USER] u with(NOLOCK) on a.UserID=u.UserID
		where a.RefID=@IncidentID  and PlatformID=@PlatformID and IsRestored=0
		and (a.CreatedAt>=GETDATE()-7 OR a.ModifiedAt>=GETDATE()-7)
		Order by a.createdAt desc

	END
END


GO
/****** Object:  StoredProcedure [dbo].[USP_UserMarkedIrrelevantList_Insert]    Script Date: 24-09-2025 12:17:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[USP_UserMarkedIrrelevantList_Insert]
@RecordIDs NVARCHAR(1000)=NULL,
@UserID INT=0,
@IncidentID INT=0,
@PlatformID INT=0,
@Reason NVARCHAR(1000)=NULL,
@IsRelevant INT=0
AS
BEGIN

	CREATE TABLE #RecordIDs
    (
        RowNum INT,
        RecordID INT
    )

    ;WITH Split AS
    (
        SELECT 
            TRIM(value) AS RecordID
        FROM STRING_SPLIT(@RecordIDs, ',')
    )
    INSERT INTO #RecordIDs (RowNum, RecordID)
    SELECT 
        ROW_NUMBER() OVER (ORDER BY (SELECT 1)) AS RowNum,
        CAST(RecordID AS INT)
    FROM Split;


	if(@PlatformID=1)
	BEGIN
		UPDATE fact_online set is_relevant_about_client = @IsRelevant,is_relevant_about_topic = @IsRelevant  where event_id=@IncidentID and tlom_id in (select RecordID from #RecordIDs)		
		UPDATE [LinkOnline_EnrichedDetail] set is_relevant_about_client = @IsRelevant,is_relevant_about_topic = @IsRelevant  
		--from [LinkOnline_EnrichedDetail] a WITH(NOLOCK)
		--INNER JOIN fact_online b WITH(NOLOCK) ON a.TLOMEID=b.tlome_id
		where TLOMID in (select RecordID from #RecordIDs)		
	END
	else if(@PlatformID=2)
	BEGIN
		UPDATE fact_print set is_relevant_about_client = @IsRelevant,is_relevant_about_topic = @IsRelevant  where eventid=@IncidentID and tlpmid in (select RecordID from #RecordIDs)		
		UPDATE [LinkPrint_EnrichedDetail] set is_relevant_about_client = @IsRelevant,is_relevant_about_topic = @IsRelevant  
		--from [LinkPrint_EnrichedDetail] a WITH(NOLOCK)
		--INNER JOIN fact_print b WITH(NOLOCK) ON a.TLPMEID=b.tlpmeid
		where TLPMID in (select RecordID from #RecordIDs)		
	END
	else if(@PlatformID=3)
	BEGIN
		UPDATE fact_twitter set is_relevant_about_client = @IsRelevant,is_relevant_about_topic = @IsRelevant  where event_id=@IncidentID and tltm_id in (select RecordID from #RecordIDs)		
		UPDATE [LinkTweet_EnrichedDetail] set is_relevant_about_client = @IsRelevant,is_relevant_about_topic = @IsRelevant  
		--from [LinkTweet_EnrichedDetail] a WITH(NOLOCK)
		--INNER JOIN fact_twitter b WITH(NOLOCK) ON a.TLTMEID=b.tltme_id
		where TLTMID in (select RecordID from #RecordIDs)		
	END
	else if(@PlatformID=4)
	BEGIN
		--UPDATE fact_YouTube set is_relevant_about_client = @IsRelevant,is_relevant_about_topic = @IsRelevant  where event_id=@IncidentID and tlym_id in (select RecordID from #RecordIDs)		
		UPDATE [LinkYouTube_EnrichedDetail] set is_relevant_about_client = @IsRelevant,is_relevant_about_topic = @IsRelevant  
		from [LinkYouTube_EnrichedDetail] a WITH(NOLOCK)
		INNER JOIN  dbo.TagLinkYouTubeMapE AS tlyme WITH(NOLOCK)  on a.TLYMEID=tlyme.TLYMEID
		where tlyme.TLYMID in (select RecordID from #RecordIDs)		
	END

	Declare @Count Int =0

	Set @Count = (select Count(RecordID) from #RecordIDs)

	WHILE(@Count>0)
	BEGIN
		
		Declare @ArticleID Int =0

		Set @ArticleID = (select RecordID from #RecordIDs where RowNum=@Count)
		
		IF(@IsRelevant=0)
		BEGIN
			IF((select COUNT(1) from UserMarkedIrrelevantList with(nolock) where RecordID=@ArticleID and RefID=@IncidentID and PlatformID=@PlatformID)=0)
			BEGIN
				INSERT INTO UserMarkedIrrelevantList(RecordID,RefID,PlatformID,Reason,IsRestored,UserID)
				VALUES(@ArticleID,@IncidentID,@PlatformID,@Reason,0,@UserID)
			END
			ELSE
			BEGIN
				Update UserMarkedIrrelevantList SET IsRestored=0,ModifiedAt=Getdate(),Reason=@Reason where  RecordID=@ArticleID and RefID=@IncidentID and PlatformID=@PlatformID
			END
		END
		ELSE IF(@IsRelevant=1)
		BEGIN
			Update UserMarkedIrrelevantList SET IsRestored=1,ModifiedAt=Getdate(),Reason=@Reason where  RecordID=@ArticleID and RefID=@IncidentID and PlatformID=@PlatformID
		END

		set @Count=@Count-1
	END
	
	drop table #RecordIDs
	select 1 as 'RecordID'
END
