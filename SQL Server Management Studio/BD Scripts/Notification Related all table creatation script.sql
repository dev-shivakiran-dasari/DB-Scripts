USE [SahadevC2]
GO

/****** Object:  Table [dbo].[Event_Notification_Log]    Script Date: 25-02-2025 14:48:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Event_Notification_Log](
	[NLID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RecordID] [int] NULL,
	[MediaTypeID] [int] NULL,
	[TopicID] [int] NULL,
	[ImageURL] [nvarchar](max) NULL,
	[NotificationText] [nvarchar](max) NULL,
	[lstDeviceID] [nvarchar](max) NULL,
	[Request] [nvarchar](max) NULL,
	[Response] [nvarchar](max) NULL,
	[CreatedAt] [smalldatetime] NULL,
	[ModifiedAt] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[NLID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Event_Notification_Log] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO



/****** Object:  Table [dbo].[Event_Notification_Log_Conditional]    Script Date: 25-02-2025 14:49:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Event_Notification_Log_Conditional](
	[NLID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RecordID] [int] NULL,
	[MediaTypeID] [int] NULL,
	[TopicID] [int] NULL,
	[ImageURL] [nvarchar](max) NULL,
	[NotificationText] [nvarchar](max) NULL,
	[lstDeviceID] [nvarchar](max) NULL,
	[Request] [nvarchar](max) NULL,
	[Response] [nvarchar](max) NULL,
	[CreatedAt] [smalldatetime] NULL,
	[ModifiedAt] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[NLID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Event_Notification_Log_Conditional] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO







/****** Object:  Table [dbo].[Event_Notification_Log_Conditional_Detail]    Script Date: 25-02-2025 14:49:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Event_Notification_Log_Conditional_Detail](
	[NLDID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[NLID] [int] NULL,
	[RecordID] [int] NULL,
	[MediaTypeID] [int] NULL,
	[TopicID] [int] NULL,
	[UserID] [int] NULL,
	[DeviceID] [varchar](200) NULL,
	[Status] [varchar](200) NULL,
	[ErrorCode] [varchar](200) NULL,
	[ErrorMessage] [varchar](1000) NULL,
	[IsRead] [int] NULL,
	[CreatedAt] [smalldatetime] NULL,
	[ModifiedAt] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[NLDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Event_Notification_Log_Conditional_Detail] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO




/****** Object:  Table [dbo].[Event_Notification_Log_Detail]    Script Date: 25-02-2025 14:50:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Event_Notification_Log_Detail](
	[NLDID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[NLID] [int] NULL,
	[RecordID] [int] NULL,
	[MediaTypeID] [int] NULL,
	[TopicID] [int] NULL,
	[UserID] [int] NULL,
	[DeviceID] [varchar](200) NULL,
	[ErrorCode] [varchar](200) NULL,
	[ErrorMessage] [varchar](1000) NULL,
	[IsRead] [int] NULL,
	[Status] [varchar](200) NULL,
	[CreatedAt] [smalldatetime] NULL,
	[ModifiedAt] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[NLDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Event_Notification_Log_Detail] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO




/****** Object:  Table [dbo].[Event_Notification_Log_SI]    Script Date: 25-02-2025 14:50:37 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Event_Notification_Log_SI](
	[NLID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[RecordID] [int] NULL,
	[MediaTypeID] [int] NULL,
	[TopicID] [int] NULL,
	[ImageURL] [nvarchar](max) NULL,
	[NotificationText] [nvarchar](max) NULL,
	[lstDeviceID] [nvarchar](max) NULL,
	[Request] [nvarchar](max) NULL,
	[Response] [nvarchar](max) NULL,
	[FromDate] [smalldatetime] NULL,
	[ToDate] [smalldatetime] NULL,
	[SummaryDetail_Json] [nvarchar](max) NULL,
	[Summary] [nvarchar](max) NULL,
	[Volume] [varchar](500) NULL,
	[CreatedAt] [smalldatetime] NULL,
	[ModifiedAt] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[NLID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

ALTER TABLE [dbo].[Event_Notification_Log_SI] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO


/****** Object:  Table [dbo].[Event_Notification_Log_SI_Detail]    Script Date: 25-02-2025 14:51:24 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Event_Notification_Log_SI_Detail](
	[NLDID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[NLID] [int] NULL,
	[RecordID] [int] NULL,
	[MediaTypeID] [int] NULL,
	[TopicID] [int] NULL,
	[UserID] [int] NULL,
	[DeviceID] [varchar](200) NULL,
	[Status] [varchar](200) NULL,
	[ErrorCode] [varchar](200) NULL,
	[ErrorMessage] [varchar](1000) NULL,
	[IsRead] [int] NULL,
	[CreatedAt] [smalldatetime] NULL,
	[ModifiedAt] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[NLDID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Event_Notification_Log_SI_Detail] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO



/****** Object:  Table [dbo].[Event_NotificationSetting]    Script Date: 25-02-2025 14:51:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Event_NotificationSetting](
	[ENSID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EventID] [int] NULL,
	[UserID] [int] NULL,
	[IsActive] [int] NULL,
	[PlatformID] [int] NULL,
	[Platform_IsActive] [int] NULL,
	[Platform_AsItHappens] [int] NULL,
	[Platform_Summarised] [int] NULL,
	[Platform_SummarisedInterval] [int] NULL,
	[Platform_Conditional] [int] NULL,
	[CreatedAt] [smalldatetime] NULL,
	[ModifiedAt] [smalldatetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[ENSID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[Event_NotificationSetting] ADD  DEFAULT ((0)) FOR [EventID]
GO

ALTER TABLE [dbo].[Event_NotificationSetting] ADD  DEFAULT ((0)) FOR [UserID]
GO

ALTER TABLE [dbo].[Event_NotificationSetting] ADD  DEFAULT ((0)) FOR [IsActive]
GO

ALTER TABLE [dbo].[Event_NotificationSetting] ADD  DEFAULT ((0)) FOR [PlatformID]
GO

ALTER TABLE [dbo].[Event_NotificationSetting] ADD  DEFAULT ((0)) FOR [Platform_IsActive]
GO

ALTER TABLE [dbo].[Event_NotificationSetting] ADD  DEFAULT ((0)) FOR [Platform_AsItHappens]
GO

ALTER TABLE [dbo].[Event_NotificationSetting] ADD  DEFAULT ((0)) FOR [Platform_Summarised]
GO

ALTER TABLE [dbo].[Event_NotificationSetting] ADD  DEFAULT ((0)) FOR [Platform_SummarisedInterval]
GO

ALTER TABLE [dbo].[Event_NotificationSetting] ADD  DEFAULT ((0)) FOR [Platform_Conditional]
GO
---------------------------------------------------------------------------------------------------------------------------------------------

USE [SahadevA]

ALTER TABLE [TagLinkOnlineMapE] ADD IsNotified TINYINT DEFAULT(0)
ALTER TABLE [TagLinkPrintMapE] ADD IsNotified TINYINT DEFAULT(0)
ALTER TABLE [dbo].[TagLinkTweetMapE] ADD IsNotified TINYINT DEFAULT(0)