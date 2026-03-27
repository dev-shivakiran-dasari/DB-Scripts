
--drop table AppVersions

--CREATE TABLE AppVersions
--(
--    AppId INT IDENTITY(1,1) PRIMARY KEY,
--    AppName VARCHAR(50) NOT NULL,          -- Dev App / UAT App / Prod App
--    CurrentVersion VARCHAR(20) NOT NULL,
--	TryCount INT default 0,
--	CreatedAt DATETIME DEFAULT GETDATE(),
--    UpdatedAt DATETIME DEFAULT GETDATE()
--);

--ALTER PROCEDURE USP_InsertOrUpdate_AppVersion
--    @AppName VARCHAR(50)=NULL,
--    @CurrentVersion VARCHAR(20)=NULL,
--	@TryCount INT=0
--AS
--BEGIN
--    SET NOCOUNT ON;

--    IF EXISTS (SELECT 1 FROM AppVersions WHERE AppName = @AppName)
--    BEGIN
--		IF(@TryCount=3)
--		BEGIN
--			UPDATE AppVersions
--			SET CurrentVersion = @CurrentVersion,
--				TryCount=@TryCount,
--			    UpdatedAt = GETDATE()
--			WHERE AppName = @AppName
--		END
--		ELSE
--		BEGIN
--			UPDATE AppVersions
--			SET TryCount=@TryCount+1,
--			    UpdatedAt = GETDATE()
--			WHERE AppName = @AppName
--		END
--    END
--    ELSE
--    BEGIN
--        INSERT INTO AppVersions (AppName, CurrentVersion,TryCount,CreatedAt)
--        VALUES (@AppName, @CurrentVersion,1,GETDATE())
--    END
--END



ALTER PROCEDURE USP_Fetch_AppVersion
    @AppName VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP 1 CurrentVersion,TryCount
    FROM AppVersions
    WHERE AppName = @AppName
END


ALTER PROC USP_Fetch_GetDeviceIDs
AS
BEGIN
	select DISTINCT DeviceID from SentryUser
END



ALTER PROCEDURE USP_InsertOrUpdate_AppVersion
    @AppName VARCHAR(50),
    @CurrentVersion VARCHAR(20),
    @IsVersionUpdate BIT 
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM AppVersions WHERE AppName = @AppName)
    BEGIN
        IF (@IsVersionUpdate = 1)
        BEGIN
            UPDATE AppVersions
            SET CurrentVersion = @CurrentVersion,
                TryCount = 1, 
                UpdatedAt = GETDATE()
            WHERE AppName = @AppName;
        END
        ELSE
        BEGIN
            UPDATE AppVersions
            SET TryCount = TryCount + 1,
                UpdatedAt = GETDATE()
            WHERE AppName = @AppName;
        END
    END
    ELSE
    BEGIN
        INSERT INTO AppVersions (AppName, CurrentVersion, TryCount, CreatedAt)
        VALUES (@AppName, @CurrentVersion, 1, GETDATE());
    END
END


-------------------------------------------------------------------------------------------------------------------


--ALTER TABLE Event_Notification_Log ADD OneSignal_DetailJson NVARCHAR(MAX)
--ALTER TABLE Event_Notification_Log_SI ADD OneSignal_DetailJson NVARCHAR(MAX)
--ALTER TABLE Event_Notification_Log_Conditional ADD OneSignal_DetailJson NVARCHAR(MAX)

--ALTER TABLE Event_Notification_Log ADD Message_ID NVARCHAR(200)
--ALTER TABLE Event_Notification_Log_SI ADD Message_ID NVARCHAR(200)
--ALTER TABLE Event_Notification_Log_Conditional ADD Message_ID NVARCHAR(200)

CREATE PROC USP_Fetch_OneSignal_PendingMessageIDs
AS
BEGIN

	select Top 10 NLID,Message_ID
	from Event_Notification_Log 
	where Message_ID IS NOT NULL
	order by CreatedAt desc
	
	select Top 10 NLID,Message_ID
	from Event_Notification_Log_Conditional 
	where Message_ID IS NOT NULL
	order by CreatedAt desc

	select Top 10 NLID,Message_ID
	from Event_Notification_Log_SI 
	where Message_ID IS NOT NULL
	order by CreatedAt desc
	
END







CREATE PROC USP_Update_OneSignal_NotificationDetail_Json
@NLID INT =0,
@Message_ID NVARCHAR(200)=NULL,
@Table_Name NVARCHAR(30)=NULL,
@OneSignal_DetailJson NVARCHAR(MAX)=NULL
AS
BEGIN
	
	IF(@Table_Name='RealTime')
	UPDATE Event_Notification_Log SET OneSignal_DetailJson=@OneSignal_DetailJson WHERE NLID=@NLID AND Message_ID=@Message_ID

	IF(@Table_Name='Conditional')
	UPDATE Event_Notification_Log_Conditional SET OneSignal_DetailJson=@OneSignal_DetailJson WHERE NLID=@NLID AND Message_ID=@Message_ID

	IF(@Table_Name='SUM')
	UPDATE Event_Notification_Log_SI SET OneSignal_DetailJson=@OneSignal_DetailJson WHERE NLID=@NLID AND Message_ID=@Message_ID

END