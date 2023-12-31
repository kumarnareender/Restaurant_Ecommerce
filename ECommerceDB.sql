USE [ECommerce]
GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorsXml]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ELMAH_GetErrorsXml]
(
    @Application NVARCHAR(60),
    @PageIndex INT = 0,
    @PageSize INT = 15,
    @TotalCount INT OUTPUT
)
AS 

    SET NOCOUNT ON

    DECLARE @FirstTimeUTC DATETIME
    DECLARE @FirstSequence INT
    DECLARE @StartRow INT
    DECLARE @StartRowIndex INT

    SELECT 
        @TotalCount = COUNT(1) 
    FROM 
        [ELMAH_Error]
    WHERE 
        [Application] = @Application

    -- Get the ID of the first error for the requested page

    SET @StartRowIndex = @PageIndex * @PageSize + 1

    IF @StartRowIndex <= @TotalCount
    BEGIN

        SET ROWCOUNT @StartRowIndex

        SELECT  
            @FirstTimeUTC = [TimeUtc],
            @FirstSequence = [Sequence]
        FROM 
            [ELMAH_Error]
        WHERE   
            [Application] = @Application
        ORDER BY 
            [TimeUtc] DESC, 
            [Sequence] DESC

    END
    ELSE
    BEGIN

        SET @PageSize = 0

    END

    -- Now set the row count to the requested page size and get
    -- all records below it for the pertaining application.

    SET ROWCOUNT @PageSize

    SELECT 
        errorId     = [ErrorId], 
        application = [Application],
        host        = [Host], 
        type        = [Type],
        source      = [Source],
        message     = [Message],
        [user]      = [User],
        statusCode  = [StatusCode], 
        time        = CONVERT(VARCHAR(50), [TimeUtc], 126) + 'Z'
    FROM 
        [ELMAH_Error] error
    WHERE
        [Application] = @Application
    AND
        [TimeUtc] <= @FirstTimeUTC
    AND 
        [Sequence] <= @FirstSequence
    ORDER BY
        [TimeUtc] DESC, 
        [Sequence] DESC
    FOR
        XML AUTO















GO
/****** Object:  StoredProcedure [dbo].[ELMAH_GetErrorXml]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ELMAH_GetErrorXml]
(
    @Application NVARCHAR(60),
    @ErrorId UNIQUEIDENTIFIER
)
AS

    SET NOCOUNT ON

    SELECT 
        [AllXml]
    FROM 
        [ELMAH_Error]
    WHERE
        [ErrorId] = @ErrorId
    AND
        [Application] = @Application















GO
/****** Object:  StoredProcedure [dbo].[ELMAH_LogError]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ELMAH_LogError]
(
    @ErrorId UNIQUEIDENTIFIER,
    @Application NVARCHAR(60),
    @Host NVARCHAR(30),
    @Type NVARCHAR(100),
    @Source NVARCHAR(60),
    @Message NVARCHAR(500),
    @User NVARCHAR(50),
    @AllXml NTEXT,
    @StatusCode INT,
    @TimeUtc DATETIME
)
AS

    SET NOCOUNT ON

    INSERT
    INTO
        [ELMAH_Error]
        (
            [ErrorId],
            [Application],
            [Host],
            [Type],
            [Source],
            [Message],
            [User],
            [AllXml],
            [StatusCode],
            [TimeUtc]
        )
    VALUES
        (
            @ErrorId,
            @Application,
            @Host,
            @Type,
            @Source,
            @Message,
            @User,
            @AllXml,
            @StatusCode,
            @TimeUtc
        )















GO
/****** Object:  Table [dbo].[ActionLogs]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ActionLogs](
	[Id] [nvarchar](128) NOT NULL,
	[Module] [nvarchar](100) NULL,
	[Description] [nvarchar](500) NULL,
	[Value] [nvarchar](200) NULL,
	[ActionType] [nvarchar](50) NULL,
	[ActionBy] [nvarchar](100) NULL,
	[ActionDate] [datetime] NULL,
 CONSTRAINT [PK_ActionLogs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Branch]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Branch](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[IsAllowOnline] [bit] NOT NULL,
 CONSTRAINT [PK_Branch] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Category]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Description] [nvarchar](200) NULL,
	[ParentId] [int] NULL,
	[DisplayOrder] [int] NULL,
	[IsPublished] [bit] NOT NULL,
	[ShowInHomepage] [bit] NULL,
	[ImageName] [nvarchar](200) NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ELMAH_Error]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ELMAH_Error](
	[ErrorId] [uniqueidentifier] NOT NULL,
	[Application] [nvarchar](60) NOT NULL,
	[Host] [nvarchar](50) NOT NULL,
	[Type] [nvarchar](100) NOT NULL,
	[Source] [nvarchar](60) NOT NULL,
	[Message] [nvarchar](500) NOT NULL,
	[User] [nvarchar](50) NOT NULL,
	[StatusCode] [int] NOT NULL,
	[TimeUtc] [datetime] NOT NULL,
	[Sequence] [int] IDENTITY(1,1) NOT NULL,
	[AllXml] [ntext] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ItemTypes]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ItemTypes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_ItemTypes] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Lookups]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Lookups](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Value] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_Lookups] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderItems]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderItems](
	[Id] [nvarchar](128) NOT NULL,
	[OrderId] [nvarchar](128) NOT NULL,
	[ProductId] [nvarchar](128) NOT NULL,
	[Quantity] [int] NOT NULL,
	[Discount] [decimal](18, 2) NULL,
	[Price] [decimal](18, 2) NOT NULL,
	[TotalPrice] [decimal](18, 2) NULL,
	[ImageUrl] [nvarchar](200) NULL,
	[ActionDate] [datetime] NOT NULL,
	[Title] [nvarchar](200) NULL,
	[CostPrice] [decimal](18, 2) NULL,
 CONSTRAINT [PK_OrderItems] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Orders]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[Id] [nvarchar](128) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[OrderCode] [nvarchar](100) NULL,
	[Barcode] [nvarchar](50) NULL,
	[PayAmount] [decimal](18, 2) NULL,
	[DueAmount] [decimal](18, 2) NULL,
	[Discount] [decimal](18, 2) NULL,
	[Vat] [decimal](18, 2) NULL,
	[ShippingAmount] [decimal](18, 2) NULL,
	[ReceiveAmount] [decimal](18, 2) NULL,
	[ChangeAmount] [decimal](18, 2) NULL,
	[OrderMode] [nvarchar](50) NOT NULL,
	[OrderStatus] [nvarchar](50) NULL,
	[PaymentStatus] [nvarchar](50) NULL,
	[PaymentType] [nvarchar](50) NULL,
	[ActionDate] [datetime] NULL,
	[ActionBy] [nvarchar](128) NULL,
	[BranchId] [int] NULL,
	[DeliveryDate] [nvarchar](100) NULL,
	[DeliveryTime] [nvarchar](50) NULL,
	[TotalWeight] [decimal](18, 2) NULL,
	[IsFrozen] [bit] NULL,
 CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductImages]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductImages](
	[Id] [nvarchar](128) NOT NULL,
	[ProductId] [nvarchar](128) NOT NULL,
	[ImageName] [nvarchar](200) NOT NULL,
	[DisplayOrder] [int] NULL,
	[IsPrimaryImage] [bit] NOT NULL,
	[IsApproved] [bit] NOT NULL,
	[ActionDate] [datetime] NULL,
 CONSTRAINT [PK_ProductImages] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Products]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[Id] [nvarchar](128) NOT NULL,
	[UserId] [nvarchar](128) NOT NULL,
	[CategoryId] [int] NOT NULL,
	[BranchId] [int] NOT NULL,
	[SupplierId] [int] NULL,
	[ItemTypeId] [int] NULL,
	[Code] [int] IDENTITY(1,1) NOT NULL,
	[ShortCode] [nvarchar](100) NOT NULL,
	[Barcode] [nvarchar](100) NULL,
	[Title] [nvarchar](200) NOT NULL,
	[Description] [nvarchar](2000) NULL,
	[IsFeatured] [bit] NULL,
	[CostPrice] [money] NULL,
	[RetailPrice] [money] NULL,
	[Quantity] [int] NOT NULL,
	[Weight] [decimal](18, 2) NULL,
	[Unit] [nvarchar](50) NULL,
	[IsDiscount] [bit] NULL,
	[DiscountType] [nvarchar](50) NULL,
	[LowStockAlert] [int] NOT NULL,
	[ViewCount] [int] NULL,
	[SoldCount] [int] NULL,
	[ExpireDate] [datetime] NULL,
	[IsInternal] [bit] NULL,
	[IsFastMoving] [bit] NULL,
	[IsMainItem] [bit] NULL,
	[IsApproved] [bit] NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[Status] [nvarchar](50) NULL,
	[ActionDate] [datetime] NOT NULL,
	[IsSync] [bit] NULL,
	[Condition] [nvarchar](100) NULL,
	[Color] [nvarchar](100) NULL,
	[Capacity] [nvarchar](100) NULL,
	[Manufacturer] [nvarchar](100) NULL,
	[ModelNumber] [nvarchar](200) NULL,
	[WarrantyPeriod] [nvarchar](100) NULL,
	[IsFrozen] [bit] NULL,
	[IMEI] [nvarchar](100) NULL,
	[WholesalePrice] [money] NULL,
	[OnlinePrice] [money] NULL,
	[RetailDiscount] [money] NULL,
	[WholesaleDiscount] [money] NULL,
	[OnlineDiscount] [money] NULL,
 CONSTRAINT [PK_Products] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ProductStocks]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductStocks](
	[Id] [nvarchar](128) NOT NULL,
	[ProductId] [nvarchar](128) NOT NULL,
	[StockLocationId] [int] NOT NULL,
	[Quantity] [int] NULL,
	[Weight] [decimal](18, 2) NULL,
	[Unit] [nvarchar](50) NULL,
 CONSTRAINT [PK_ProductStockLocations] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Purchase]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Purchase](
	[Id] [nvarchar](128) NOT NULL,
	[ProductId] [nvarchar](128) NOT NULL,
	[SupplierId] [int] NOT NULL,
	[Quantity] [int] NULL,
	[Weight] [decimal](18, 2) NULL,
	[Unit] [nvarchar](50) NULL,
	[Tax] [decimal](18, 2) NULL,
	[Price] [money] NOT NULL,
	[PurchaseDate] [datetime] NOT NULL,
	[ActionDate] [datetime] NOT NULL,
 CONSTRAINT [PK_Purchase] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Roles]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Roles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_dbo.Roles] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Settings]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Settings](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
	[Value] [nvarchar](200) NULL,
 CONSTRAINT [PK_Settings] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[SliderImages]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SliderImages](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ImageName] [nvarchar](200) NOT NULL,
	[DisplayOrder] [int] NULL,
	[Url] [nvarchar](200) NULL,
 CONSTRAINT [PK_SliderImages] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[StockLocations]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StockLocations](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_StockLocation] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Suppliers]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Suppliers](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Suppliers] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserBranches]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserBranches](
	[UserId] [nvarchar](128) NOT NULL,
	[BranchId] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[UserRoles]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserRoles](
	[UserId] [nvarchar](128) NOT NULL,
	[RoleId] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Users]    Script Date: 8/11/2022 9:55:48 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [nvarchar](128) NOT NULL,
	[Username] [nvarchar](100) NOT NULL,
	[Password] [nvarchar](100) NOT NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL,
	[ShipAddress] [nvarchar](500) NULL,
	[ShipZipCode] [nvarchar](50) NULL,
	[ShipCity] [nvarchar](50) NULL,
	[ShipState] [nvarchar](50) NULL,
	[ShipCountry] [nvarchar](50) NULL,
	[PhotoUrl] [nvarchar](200) NULL,
	[LastLoginTime] [datetime] NULL,
	[CreateDate] [datetime] NOT NULL,
	[IsManual] [bit] NULL,
	[IsVerified] [bit] NOT NULL,
	[IsActive] [bit] NOT NULL,
	[IsDelete] [bit] NOT NULL,
	[IsSync] [bit] NULL,
	[Code] [nvarchar](200) NULL,
	[Permissions] [nvarchar](500) NULL,
	[CustomerCode] [int] IDENTITY(1001,1) NOT NULL,
 CONSTRAINT [PK_dbo.Users] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'0ccf0f2b-18a1-432f-a3a1-39d939898144', N'Product', N'Delete Product', N'Product Id: 3c344ce0-732c-41c8-afe6-ef1d312a203c', N'Delete', N'admin', CAST(0x0000AEDD00F02AD8 AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'20c9d10f-d7a8-445d-9b29-374fc078d4ec', N'Product', N'Product Update', N'Product Name: Rice Flour', N'Update', N'admin', CAST(0x0000AEDD00EF0C45 AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'2552c705-7f1d-46f7-a9c4-a16f52668ba9', N'Product', N'Product Update', N'Product Name: Taste Pinut Item', N'Update', N'admin', CAST(0x0000AEDD00EE5E85 AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'48f9a6bf-a905-4a17-9bf2-402d237b6a83', N'Product', N'Product Update', N'Product Name: Frozen Chicken Meat', N'Update', N'admin', CAST(0x0000AEDE00B72245 AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'6dd6745c-07e1-4922-8037-898e4990db18', N'Product', N'Product Update', N'Product Name: Milk Canned Item', N'Update', N'admin', CAST(0x0000AEDE00B62056 AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'790c07c0-b396-4c6b-95e6-39d749edfc7b', N'Product', N'Product Update', N'Product Name: Orange Juice Item', N'Update', N'admin', CAST(0x0000AEDD00EEB29A AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'a1137a54-bf3c-49fa-a659-c6ab2f8cf714', N'Product', N'Product Update', N'Product Name: Rice Powder', N'Update', N'admin', CAST(0x0000AEDD00EE8E12 AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'c1fe6825-b2c4-4f2e-82b3-48eb4ff1e34d', N'Product', N'Product Update', N'Product Name: Orange Juice Item', N'Update', N'admin', CAST(0x0000AEDE00B65A06 AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'cc8d54d2-57d9-4126-93bd-55023dac4ffd', N'Product', N'Product Update', N'Product Name: Nido Baby Milk', N'Update', N'admin', CAST(0x0000AEDD00EEE14B AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'd181879c-a9c3-49aa-9374-92f3d4d14fb5', N'Product', N'Product Update', N'Product Name: Taste Pinut Item', N'Update', N'admin', CAST(0x0000AEDE00B6E892 AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'd1c57165-0b27-4371-8498-3f9e698128f8', N'Product', N'Product Update', N'Product Name: Milk Canned Item', N'Update', N'admin', CAST(0x0000AEDD00EF1E7F AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'db2a20bb-1bc1-407f-a404-05dc7696e350', N'Product', N'Delete Product', N'Product Id: 5c6edc43-9967-412a-9326-d7fba4b72861', N'Delete', N'admin', CAST(0x0000AEDD00F0BBEB AS DateTime))
INSERT [dbo].[ActionLogs] ([Id], [Module], [Description], [Value], [ActionType], [ActionBy], [ActionDate]) VALUES (N'ea5cab62-0351-4d5f-96d1-a6c2dc1f901a', N'Product', N'Product Update', N'Product Name: White Rice Flour', N'Update', N'admin', CAST(0x0000AEDD00EE39FD AS DateTime))
SET IDENTITY_INSERT [dbo].[Branch] ON 

INSERT [dbo].[Branch] ([Id], [Name], [IsAllowOnline]) VALUES (4, N'Main Branch', 1)
SET IDENTITY_INSERT [dbo].[Branch] OFF
SET IDENTITY_INSERT [dbo].[Category] ON 

INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (174, N'Meat', NULL, NULL, 1, 1, 1, N'174.jpg')
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (175, N'Beef', NULL, 174, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (176, N'Chicken', NULL, 174, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (177, N'Fish', NULL, NULL, 20, 1, 1, N'177.jpg')
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (178, N'Canned Fish', NULL, 177, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (179, N'Sea Food', NULL, 177, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (180, N'Fruits & Vegetables', NULL, NULL, 30, 1, 1, N'180.jpg')
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (181, N'Fruits', NULL, 180, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (182, N'Vegetables', NULL, 180, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (183, N'Bread & Cakes', NULL, NULL, 40, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (184, N'Breads', NULL, 183, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (185, N'Cakes', NULL, 183, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (186, N'Baby Foods', NULL, NULL, 50, 1, 1, N'186.jpg')
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (187, N'Milk Items', NULL, 186, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (188, N'Baby Meals', NULL, 186, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (189, N'Drinks & Beverage', NULL, NULL, 60, 1, 1, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (190, N'Juice', NULL, 189, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (191, N'Tea & Coffee', NULL, 189, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (192, N'Bread & Bekery', NULL, NULL, 70, 1, 1, N'192.jpg')
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (193, N'White Bread', NULL, 192, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (194, N'Nan Bread', NULL, 192, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (195, N'Donut', NULL, 192, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (196, N'Soft Drinks', NULL, 189, NULL, 1, NULL, NULL)
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (197, N'Pinuts', NULL, NULL, 80, 1, 0, N'197.jpg')
INSERT [dbo].[Category] ([Id], [Name], [Description], [ParentId], [DisplayOrder], [IsPublished], [ShowInHomepage], [ImageName]) VALUES (198, N'Rice & Flour', NULL, NULL, 90, 1, 1, N'198.jpg')
SET IDENTITY_INSERT [dbo].[Category] OFF
SET IDENTITY_INSERT [dbo].[ELMAH_Error] ON 

INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'0bd6223c-8c70-4585-b165-e6a2064e7db5', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.InvalidOperationException', N'EntityFramework', N'The cast to value type ''System.Decimal'' failed because the materialized value is null. Either the result type''s generic parameter or the query must use a nullable type.', N'admin', 0, CAST(0x0000AEDD001AC8DB AS DateTime), 8619, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.InvalidOperationException"
  message="The cast to value type ''System.Decimal'' failed because the materialized value is null. Either the result type''s generic parameter or the query must use a nullable type."
  source="EntityFramework"
  detail="System.InvalidOperationException: The cast to value type ''System.Decimal'' failed because the materialized value is null. Either the result type''s generic parameter or the query must use a nullable type.&#xD;&#xA;   at System.Data.Entity.Core.Common.Internal.Materialization.Shaper.ErrorHandlingValueReader`1.GetValue(DbDataReader reader, Int32 ordinal)&#xD;&#xA;   at lambda_method(Closure , Shaper )&#xD;&#xA;   at System.Data.Entity.Core.Common.Internal.Materialization.Coordinator`1.ReadNextElement(Shaper shaper)&#xD;&#xA;   at System.Data.Entity.Core.Common.Internal.Materialization.Shaper`1.SimpleEnumerator.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Web.Controllers.AdminController.GetTotalItemValues() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\AdminController.cs:line 467&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-07-25T01:37:31.1823846Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=gq5j20wgd3fzp1orpi1sgjkc; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1658713046604%7D; .ASPXAUTH=7F2EC86B829CCB4472A3ED89A74476BDCF747B38D768B6D5B7F54E56BDF8F141A21297DDCD63FA286073BEFB53981015C0ADA663DF7219990EBD7F35065EB84EE905ADD9AB4F0AB9D7DAE6BC987D8FB21A09D40FA63401E9148E2D7B790DA3BE&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;.Not/A)Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;103&quot;, &quot;Chromium&quot;;v=&quot;103&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=gq5j20wgd3fzp1orpi1sgjkc; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1658713046604%7D; .ASPXAUTH=7F2EC86B829CCB4472A3ED89A74476BDCF747B38D768B6D5B7F54E56BDF8F141A21297DDCD63FA286073BEFB53981015C0ADA663DF7219990EBD7F35065EB84EE905ADD9AB4F0AB9D7DAE6BC987D8FB21A09D40FA63401E9148E2D7B790DA3BE&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;.Not/A)Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;103&quot;, &quot;Chromium&quot;;v=&quot;103&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Admin/GetTotalItemValues" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Admin\GetTotalItemValues" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="30557" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Admin/GetTotalItemValues" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Admin/GetTotalItemValues" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=gq5j20wgd3fzp1orpi1sgjkc; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1658713046604%7D; .ASPXAUTH=7F2EC86B829CCB4472A3ED89A74476BDCF747B38D768B6D5B7F54E56BDF8F141A21297DDCD63FA286073BEFB53981015C0ADA663DF7219990EBD7F35065EB84EE905ADD9AB4F0AB9D7DAE6BC987D8FB21A09D40FA63401E9148E2D7B790DA3BE" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;.Not/A)Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;103&quot;, &quot;Chromium&quot;;v=&quot;103&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="gq5j20wgd3fzp1orpi1sgjkc" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1658713046604%7D" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="7F2EC86B829CCB4472A3ED89A74476BDCF747B38D768B6D5B7F54E56BDF8F141A21297DDCD63FA286073BEFB53981015C0ADA663DF7219990EBD7F35065EB84EE905ADD9AB4F0AB9D7DAE6BC987D8FB21A09D40FA63401E9148E2D7B790DA3BE" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'f64e73bc-7813-47f9-9726-39f87f1fd3c2', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D2982 AS DateTime), 8622, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 70&#xD;&#xA;   at Application.Controllers.CategoryController.GetCategoryTree() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 110&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:10.5658441Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_CONTENT_TYPE:application/json&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Content-Type: application/json&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetCategoryTree" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16290" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'487dea92-f71c-4ab2-a5ef-97857cb2a634', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D29E2 AS DateTime), 8623, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:10.8866604Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:application/json, text/plain, */*&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: application/json, text/plain, */*&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16297" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/plain, */*" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'6b5eac5d-5a8f-49b8-8fde-fddfa2c04cf2', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D39D0 AS DateTime), 8625, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:24.4813602Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_CONTENT_TYPE:application/json&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Security/Login&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Content-Type: application/json&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Security/Login&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16290" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Security/Login" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'c4dc49f9-f6b7-41ba-94af-89c6a96d7e61', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D39EB AS DateTime), 8627, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:24.5693105Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Security/Login&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Security/Login&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16289" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Security/Login" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'57344a71-c6ed-4e01-b604-72a905e8e3da', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D3E36 AS DateTime), 8628, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:28.2324082Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_CONTENT_TYPE:application/json&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Content-Type: application/json&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16289" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'379403f3-48d9-4449-82c9-ae061efd21ce', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D3E45 AS DateTime), 8629, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 70&#xD;&#xA;   at Application.Controllers.CategoryController.GetCategoryTree() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 110&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:28.2823818Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_CONTENT_TYPE:application/json&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Content-Type: application/json&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetCategoryTree" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16293" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'20bddd6a-6ecc-42de-9ab9-ffc3645348ad', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D3EF1 AS DateTime), 8630, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:28.8564095Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16297" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750385389%7D" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'635cf1bc-ae0a-493b-bd9a-74bcf0e44dd4', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D4A47 AS DateTime), 8631, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:38.5313364Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_CONTENT_TYPE:application/json&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin/Category&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Content-Type: application/json&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin/Category&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16290" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin/Category" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'24f0c90a-6019-4504-8f47-b074db791b7d', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D4A54 AS DateTime), 8632, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 74&#xD;&#xA;   at Application.Controllers.CategoryController.GetCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 254&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:38.5723159Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:application/json, text/plain, */*&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin/Category&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: application/json, text/plain, */*&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin/Category&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16290" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/plain, */*" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin/Category" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'0eb246f9-01f4-4d73-9a38-312cb996e71c', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D4B00 AS DateTime), 8633, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:39.1462824Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin/Category&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin/Category&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16297" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin/Category" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'46682550-cdaf-4d9f-896a-b811391ae66b', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D4B87 AS DateTime), 8634, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 70&#xD;&#xA;   at Application.Controllers.CategoryController.GetCategoryTree() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 110&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:39.5979789Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_CONTENT_TYPE:application/json&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin/Category&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Content-Type: application/json&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin/Category&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetCategoryTree" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16289" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin/Category" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750389444%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'28b63d2c-d977-496c-a378-35aeeb42cbba', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D5061 AS DateTime), 8635, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:43.7359312Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_CONTENT_TYPE:application/json&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin/Category&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Content-Type: application/json&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin/Category&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16289" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin/Category" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'aebab810-314e-4982-9201-5cf3e2df4d4c', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D5070 AS DateTime), 8636, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 74&#xD;&#xA;   at Application.Controllers.CategoryController.GetCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 254&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:43.7879017Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:application/json, text/plain, */*&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin/Category&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: application/json, text/plain, */*&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin/Category&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16297" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/plain, */*" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin/Category" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'a98e3d30-d30b-4b58-8db7-2bd98eb9be9b', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D5118 AS DateTime), 8637, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:44.3472294Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin/Category&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin/Category&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16290" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin/Category" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'4a967ecd-4237-4b58-9b48-4f12414cb389', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D51A4 AS DateTime), 8638, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 70&#xD;&#xA;   at Application.Controllers.CategoryController.GetCategoryTree() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 110&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:44.8129530Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_CONTENT_TYPE:application/json&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Admin/Category&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Content-Type: application/json&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Admin/Category&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetCategoryTree" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16289" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Admin/Category" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750399844%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'9921abce-09b5-44ba-a977-fa764fa3ec51', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D6243 AS DateTime), 8639, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:58.9976616Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750404737%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_UPGRADE_INSECURE_REQUESTS:1&#xD;&#xA;HTTP_SEC_FETCH_SITE:none&#xD;&#xA;HTTP_SEC_FETCH_MODE:navigate&#xD;&#xA;HTTP_SEC_FETCH_USER:?1&#xD;&#xA;HTTP_SEC_FETCH_DEST:document&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750404737%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Upgrade-Insecure-Requests: 1&#xD;&#xA;Sec-Fetch-Site: none&#xD;&#xA;Sec-Fetch-Mode: navigate&#xD;&#xA;Sec-Fetch-User: ?1&#xD;&#xA;Sec-Fetch-Dest: document&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16297" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750404737%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_UPGRADE_INSECURE_REQUESTS">
      <value
        string="1" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="none" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="navigate" />
    </item>
    <item
      name="HTTP_SEC_FETCH_USER">
      <value
        string="?1" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="document" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="ACF930BE65C38868CD3E6D6572EABDE6F67075531CBEDEB999DA7D8C0F64FEE806A10AF459E50AC4BF14AF4930059F091F085584714F6C1D76D8D9DF8E795D27E901B9CFF53899163E2CB94249E2E95646ABDDC3F4419E9EE89C5F4EF3D270B1" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750404737%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'32cd0915-f334-4a60-999b-eadc7cfde456', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Web.HttpException', N'System.Web.Mvc', N'A public action method ''CopyProduct'' was not found on controller ''Application.Web.Controllers.ProductEntryController''.', N'admin', 404, CAST(0x0000AEEA00AEB6ED AS DateTime), 8642, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Web.HttpException"
  message="A public action method ''CopyProduct'' was not found on controller ''Application.Web.Controllers.ProductEntryController''."
  source="System.Web.Mvc"
  detail="System.Web.HttpException (0x80004005): A public action method ''CopyProduct'' was not found on controller ''Application.Web.Controllers.ProductEntryController''.&#xD;&#xA;   at System.Web.Mvc.Controller.HandleUnknownAction(String actionName)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-07T10:36:06.9775917Z"
  statusCode="404">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:application/json, text/plain, */*&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=pkz4qtu0y1i3kmyqd1sr1ljh; SchoolName=Gojmohal Tannery High School; SchoolAddress=; SchoolWebsite=; FourSubjectBaseMark=2; ReportModel_Term=Format2; ReportModel_Final=; AcademicYearStartMonth=; ThermalPrint=false; FineAccHead=বেতন; FeesCollectionSMS=; Fees_Receipt_Format=; Voucher_Receipt_Format=; ReportCard_SchoolName=Gojmohal Tannery High School; ReportCard_SchoolAddress=Gojmohal School, Hazaribagh, Dhaka, 1209 Dhaka,; ReportCard_ProgressReportText=Progress  Report-2022; ReportCard_ShowGrandTotal=true; ReportCard_NoMeritOnFail=true; ReportCard_ShowLogo=true; ReportCard_ShowPhoto=true; ReportCard_MeritPosition_NonGroup=ByClassSingleGroup; ReportCard_MeritPosition_Group=ByClassSingleGroup; ReportCard_Show_GPA_LetterGrade=; HeadTeacher_Name=SUFIA  KHATUN; PaymentReceived_SMS_Allow=; PaymentReceived_SMS_Text=; AlertMessage=; MeritPosition=; SMS_Provider=; SMS_Mask=; AdmissionForm_HeaderText=; AdmissionForm_DateTime=; AdmissionForm_AdmitCard_Format=; IDFormat=; FreeText=; DummySubjectNameSuffix=; StudentAttendanceRestriction=; Allow_Student_Profile_Edit=; Allow_Student_Password_Change=; AdmitCardFormat=; ResultSmsTo=; ShowFinalTermCalculationNote=; FinalResult_GraceNumber=; WorkingDays=; MeritByTotalNumber=; ExamNumberEntry_LockDate=; Zoom_Email=; Zoom_Api_Key=; Zoom_Api_Secret=; .ASPXAUTH=6F3CBC9C7EC8CE6AD02B52E23EAA5FF654A4B4EC76E366FD2E08FA3735374729AE28AC2F786F65F9AE199F2A3C8A0502E85B4C24ABB6DC5C60971924302B77A72B1CF6D4811098888C3F4689FE52DF940BAB751170908BA7660B0CD7FB765141; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659868548288%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/ProductEntry/Post?load=all&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: application/json, text/plain, */*&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=pkz4qtu0y1i3kmyqd1sr1ljh; SchoolName=Gojmohal Tannery High School; SchoolAddress=; SchoolWebsite=; FourSubjectBaseMark=2; ReportModel_Term=Format2; ReportModel_Final=; AcademicYearStartMonth=; ThermalPrint=false; FineAccHead=বেতন; FeesCollectionSMS=; Fees_Receipt_Format=; Voucher_Receipt_Format=; ReportCard_SchoolName=Gojmohal Tannery High School; ReportCard_SchoolAddress=Gojmohal School, Hazaribagh, Dhaka, 1209 Dhaka,; ReportCard_ProgressReportText=Progress  Report-2022; ReportCard_ShowGrandTotal=true; ReportCard_NoMeritOnFail=true; ReportCard_ShowLogo=true; ReportCard_ShowPhoto=true; ReportCard_MeritPosition_NonGroup=ByClassSingleGroup; ReportCard_MeritPosition_Group=ByClassSingleGroup; ReportCard_Show_GPA_LetterGrade=; HeadTeacher_Name=SUFIA  KHATUN; PaymentReceived_SMS_Allow=; PaymentReceived_SMS_Text=; AlertMessage=; MeritPosition=; SMS_Provider=; SMS_Mask=; AdmissionForm_HeaderText=; AdmissionForm_DateTime=; AdmissionForm_AdmitCard_Format=; IDFormat=; FreeText=; DummySubjectNameSuffix=; StudentAttendanceRestriction=; Allow_Student_Profile_Edit=; Allow_Student_Password_Change=; AdmitCardFormat=; ResultSmsTo=; ShowFinalTermCalculationNote=; FinalResult_GraceNumber=; WorkingDays=; MeritByTotalNumber=; ExamNumberEntry_LockDate=; Zoom_Email=; Zoom_Api_Key=; Zoom_Api_Secret=; .ASPXAUTH=6F3CBC9C7EC8CE6AD02B52E23EAA5FF654A4B4EC76E366FD2E08FA3735374729AE28AC2F786F65F9AE199F2A3C8A0502E85B4C24ABB6DC5C60971924302B77A72B1CF6D4811098888C3F4689FE52DF940BAB751170908BA7660B0CD7FB765141; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659868548288%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/ProductEntry/Post?load=all&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/ProductEntry/CopyProduct" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\ProductEntry\CopyProduct" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="barcode=undefined" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="26851" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/ProductEntry/CopyProduct" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/ProductEntry/CopyProduct" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/plain, */*" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=pkz4qtu0y1i3kmyqd1sr1ljh; SchoolName=Gojmohal Tannery High School; SchoolAddress=; SchoolWebsite=; FourSubjectBaseMark=2; ReportModel_Term=Format2; ReportModel_Final=; AcademicYearStartMonth=; ThermalPrint=false; FineAccHead=বেতন; FeesCollectionSMS=; Fees_Receipt_Format=; Voucher_Receipt_Format=; ReportCard_SchoolName=Gojmohal Tannery High School; ReportCard_SchoolAddress=Gojmohal School, Hazaribagh, Dhaka, 1209 Dhaka,; ReportCard_ProgressReportText=Progress  Report-2022; ReportCard_ShowGrandTotal=true; ReportCard_NoMeritOnFail=true; ReportCard_ShowLogo=true; ReportCard_ShowPhoto=true; ReportCard_MeritPosition_NonGroup=ByClassSingleGroup; ReportCard_MeritPosition_Group=ByClassSingleGroup; ReportCard_Show_GPA_LetterGrade=; HeadTeacher_Name=SUFIA  KHATUN; PaymentReceived_SMS_Allow=; PaymentReceived_SMS_Text=; AlertMessage=; MeritPosition=; SMS_Provider=; SMS_Mask=; AdmissionForm_HeaderText=; AdmissionForm_DateTime=; AdmissionForm_AdmitCard_Format=; IDFormat=; FreeText=; DummySubjectNameSuffix=; StudentAttendanceRestriction=; Allow_Student_Profile_Edit=; Allow_Student_Password_Change=; AdmitCardFormat=; ResultSmsTo=; ShowFinalTermCalculationNote=; FinalResult_GraceNumber=; WorkingDays=; MeritByTotalNumber=; ExamNumberEntry_LockDate=; Zoom_Email=; Zoom_Api_Key=; Zoom_Api_Secret=; .ASPXAUTH=6F3CBC9C7EC8CE6AD02B52E23EAA5FF654A4B4EC76E366FD2E08FA3735374729AE28AC2F786F65F9AE199F2A3C8A0502E85B4C24ABB6DC5C60971924302B77A72B1CF6D4811098888C3F4689FE52DF940BAB751170908BA7660B0CD7FB765141; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659868548288%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/ProductEntry/Post?load=all" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <queryString>
    <item
      name="barcode">
      <value
        string="undefined" />
    </item>
  </queryString>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="pkz4qtu0y1i3kmyqd1sr1ljh" />
    </item>
    <item
      name="SchoolName">
      <value
        string="Gojmohal Tannery High School" />
    </item>
    <item
      name="SchoolAddress">
      <value
        string="" />
    </item>
    <item
      name="SchoolWebsite">
      <value
        string="" />
    </item>
    <item
      name="FourSubjectBaseMark">
      <value
        string="2" />
    </item>
    <item
      name="ReportModel_Term">
      <value
        string="Format2" />
    </item>
    <item
      name="ReportModel_Final">
      <value
        string="" />
    </item>
    <item
      name="AcademicYearStartMonth">
      <value
        string="" />
    </item>
    <item
      name="ThermalPrint">
      <value
        string="false" />
    </item>
    <item
      name="FineAccHead">
      <value
        string="বেতন" />
    </item>
    <item
      name="FeesCollectionSMS">
      <value
        string="" />
    </item>
    <item
      name="Fees_Receipt_Format">
      <value
        string="" />
    </item>
    <item
      name="Voucher_Receipt_Format">
      <value
        string="" />
    </item>
    <item
      name="ReportCard_SchoolName">
      <value
        string="Gojmohal Tannery High School" />
    </item>
    <item
      name="ReportCard_SchoolAddress">
      <value
        string="Gojmohal School, Hazaribagh, Dhaka, 1209 Dhaka," />
    </item>
    <item
      name="ReportCard_ProgressReportText">
      <value
        string="Progress  Report-2022" />
    </item>
    <item
      name="ReportCard_ShowGrandTotal">
      <value
        string="true" />
    </item>
    <item
      name="ReportCard_NoMeritOnFail">
      <value
        string="true" />
    </item>
    <item
      name="ReportCard_ShowLogo">
      <value
        string="true" />
    </item>
    <item
      name="ReportCard_ShowPhoto">
      <value
        string="true" />
    </item>
    <item
      name="ReportCard_MeritPosition_NonGroup">
      <value
        string="ByClassSingleGroup" />
    </item>
    <item
      name="ReportCard_MeritPosition_Group">
      <value
        string="ByClassSingleGroup" />
    </item>
    <item
      name="ReportCard_Show_GPA_LetterGrade">
      <value
        string="" />
    </item>
    <item
      name="HeadTeacher_Name">
      <value
        string="SUFIA  KHATUN" />
    </item>
    <item
      name="PaymentReceived_SMS_Allow">
      <value
        string="" />
    </item>
    <item
      name="PaymentReceived_SMS_Text">
      <value
        string="" />
    </item>
    <item
      name="AlertMessage">
      <value
        string="" />
    </item>
    <item
      name="MeritPosition">
      <value
        string="" />
    </item>
    <item
      name="SMS_Provider">
      <value
        string="" />
    </item>
    <item
      name="SMS_Mask">
      <value
        string="" />
    </item>
    <item
      name="AdmissionForm_HeaderText">
      <value
        string="" />
    </item>
    <item
      name="AdmissionForm_DateTime">
      <value
        string="" />
    </item>
    <item
      name="AdmissionForm_AdmitCard_Format">
      <value
        string="" />
    </item>
    <item
      name="IDFormat">
      <value
        string="" />
    </item>
    <item
      name="FreeText">
      <value
        string="" />
    </item>
    <item
      name="DummySubjectNameSuffix">
      <value
        string="" />
    </item>
    <item
      name="StudentAttendanceRestriction">
      <value
        string="" />
    </item>
    <item
      name="Allow_Student_Profile_Edit">
      <value
        string="" />
    </item>
    <item
      name="Allow_Student_Password_Change">
      <value
        string="" />
    </item>
    <item
      name="AdmitCardFormat">
      <value
        string="" />
    </item>
    <item
      name="ResultSmsTo">
      <value
        string="" />
    </item>
    <item
      name="ShowFinalTermCalculationNote">
      <value
        string="" />
    </item>
    <item
      name="FinalResult_GraceNumber">
      <value
        string="" />
    </item>
    <item
      name="WorkingDays">
      <value
        string="" />
    </item>
    <item
      name="MeritByTotalNumber">
      <value
        string="" />
    </item>
    <item
      name="ExamNumberEntry_LockDate">
      <value
        string="" />
    </item>
    <item
      name="Zoom_Email">
      <value
        string="" />
    </item>
    <item
      name="Zoom_Api_Key">
      <value
        string="" />
    </item>
    <item
      name="Zoom_Api_Secret">
      <value
        string="" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="6F3CBC9C7EC8CE6AD02B52E23EAA5FF654A4B4EC76E366FD2E08FA3735374729AE28AC2F786F65F9AE199F2A3C8A0502E85B4C24ABB6DC5C60971924302B77A72B1CF6D4811098888C3F4689FE52DF940BAB751170908BA7660B0CD7FB765141" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659868548288%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'82e28214-e95f-4497-8134-df7fe180baab', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D29F7 AS DateTime), 8624, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:10.9556207Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16290" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'ed2d5d56-d7fd-4003-9e33-c4f1ff818164', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D2982 AS DateTime), 8621, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 59&#xD;&#xA;   at Application.Controllers.CategoryController.GetParentCategoryList() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 86&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:10.5658441Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_CONTENT_TYPE:application/json&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Content-Type: application/json&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetParentCategoryList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16289" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetParentCategoryList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750257056%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'1aa957d8-a6c0-468f-8235-73268f4be025', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Data.SqlClient.SqlException', N'.Net SqlClient Data Provider', N'Invalid column name ''ImageName''.', N'admin', 0, CAST(0x0000AEE9001D39DA AS DateTime), 8626, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Data.SqlClient.SqlException"
  message="Invalid column name ''ImageName''."
  source=".Net SqlClient Data Provider"
  detail="System.Data.Entity.Core.EntityCommandExecutionException: An error occurred while executing the command definition. See the inner exception for details. ---&gt; System.Data.SqlClient.SqlException: Invalid column name ''ImageName''.&#xD;&#xA;   at System.Data.SqlClient.SqlConnection.OnError(SqlException exception, Boolean breakConnection, Action`1 wrapCloseInAction)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.ThrowExceptionAndWarning(TdsParserStateObject stateObj, Boolean callerHasConnectionLock, Boolean asyncClose)&#xD;&#xA;   at System.Data.SqlClient.TdsParser.TryRun(RunBehavior runBehavior, SqlCommand cmdHandler, SqlDataReader dataStream, BulkCopySimpleResultSet bulkCopyHandler, TdsParserStateObject stateObj, Boolean&amp; dataReady)&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.TryConsumeMetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlDataReader.get_MetaData()&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.FinishExecuteReader(SqlDataReader ds, RunBehavior runBehavior, String resetOptionsString, Boolean isInternal, Boolean forDescribeParameterEncryption, Boolean shouldCacheForAlwaysEncrypted)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReaderTds(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, Boolean async, Int32 timeout, Task&amp; task, Boolean asyncWrite, Boolean inRetry, SqlDataReader ds, Boolean describeParameterEncryptionRequest)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method, TaskCompletionSource`1 completion, Int32 timeout, Task&amp; task, Boolean&amp; usedCache, Boolean asyncWrite, Boolean inRetry)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.RunExecuteReader(CommandBehavior cmdBehavior, RunBehavior runBehavior, Boolean returnStream, String method)&#xD;&#xA;   at System.Data.SqlClient.SqlCommand.ExecuteReader(CommandBehavior behavior, String method)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.InternalDispatcher`1.Dispatch[TTarget,TInterceptionContext,TResult](TTarget target, Func`3 operation, TInterceptionContext interceptionContext, Action`3 executing, Action`3 executed)&#xD;&#xA;   at System.Data.Entity.Infrastructure.Interception.DbCommandDispatcher.Reader(DbCommand command, DbCommandInterceptionContext interceptionContext)&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   --- End of inner exception stack trace ---&#xD;&#xA;   at System.Data.Entity.Core.EntityClient.Internal.EntityCommandDefinition.ExecuteStoreCommands(EntityCommand entityCommand, CommandBehavior behavior)&#xD;&#xA;   at System.Data.Entity.Core.Objects.Internal.ObjectQueryExecutionPlan.Execute[TResultType](ObjectContext context, ObjectParameterCollection parameterValues)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectContext.ExecuteInTransaction[T](Func`1 func, IDbExecutionStrategy executionStrategy, Boolean startLocalTransaction, Boolean releaseConnectionOnSuccess)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;&gt;c__DisplayClass7.&lt;GetResults&gt;b__5()&#xD;&#xA;   at System.Data.Entity.SqlServer.DefaultSqlExecutionStrategy.Execute[TResult](Func`1 operation)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.GetResults(Nullable`1 forMergeOption)&#xD;&#xA;   at System.Data.Entity.Core.Objects.ObjectQuery`1.&lt;System.Collections.Generic.IEnumerable&lt;T&gt;.GetEnumerator&gt;b__0()&#xD;&#xA;   at System.Data.Entity.Internal.LazyEnumerator`1.MoveNext()&#xD;&#xA;   at System.Collections.Generic.List`1..ctor(IEnumerable`1 collection)&#xD;&#xA;   at System.Linq.Enumerable.ToList[TSource](IEnumerable`1 source)&#xD;&#xA;   at Application.Data.Infrastructure.RepositoryBase`1.GetMany(Expression`1 where) in D:\Projects\Git\MyTemplates\ECommerce\Application.Data\Infrastructure\RepositoryBase.cs:line 66&#xD;&#xA;   at Application.Service.CategoryService.GetCategoryList(Boolean isParentsOnly, Boolean isPublishedOnly) in D:\Projects\Git\MyTemplates\ECommerce\Application.Service\CategoryService.cs:line 70&#xD;&#xA;   at Application.Controllers.CategoryController.GetCategoryTree() in D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Controllers\CategoryController.cs:line 110&#xD;&#xA;   at lambda_method(Closure , ControllerBase , Object[] )&#xD;&#xA;   at System.Web.Mvc.ReflectedActionDescriptor.Execute(ControllerContext controllerContext, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.ControllerActionInvoker.InvokeActionMethod(ControllerContext controllerContext, ActionDescriptor actionDescriptor, IDictionary`2 parameters)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;BeginInvokeSynchronousActionMethod&gt;b__36(IAsyncResult asyncResult, ActionInvocation innerInvokeState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncResult`2.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethod(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3c()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.AsyncInvocationWithFilters.&lt;&gt;c__DisplayClass45.&lt;InvokeActionMethodFilterAsynchronouslyRecursive&gt;b__3e()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeActionMethodWithFilters(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;&gt;c__DisplayClass28.&lt;BeginInvokeAction&gt;b__19()&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.&lt;&gt;c__DisplayClass1e.&lt;BeginInvokeAction&gt;b__1b(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncControllerActionInvoker.EndInvokeAction(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.&lt;BeginExecuteCore&gt;b__1d(IAsyncResult asyncResult, ExecuteCoreState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecuteCore(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.Controller.EndExecute(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.&lt;BeginProcessRequest&gt;b__4(IAsyncResult asyncResult, ProcessRequestState innerState)&#xD;&#xA;   at System.Web.Mvc.Async.AsyncResultWrapper.WrappedAsyncVoid`1.CallEndDelegate(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.EndProcessRequest(IAsyncResult asyncResult)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T01:46:24.5133441Z">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_CONTENT_TYPE:application/json&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Security/Login&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_X_REQUESTED_WITH:XMLHttpRequest&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Content-Type: application/json&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Security/Login&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;X-Requested-With: XMLHttpRequest&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Category\GetCategoryTree" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16297" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Category/GetCategoryTree" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_CONTENT_TYPE">
      <value
        string="application/json" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; .ASPXAUTH=A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Security/Login" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_X_REQUESTED_WITH">
      <value
        string="XMLHttpRequest" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="A82677002431670FD4AA526DDEFA15D65232A8A9B074173ECE57404407A7FC1522409373BB16BB88D14DFBAAFFA62C1A553A563A8F03A19AF6066319311C98D940D9FC6A2BAB4F397C8830554AF02222434A7A26D609AC481BB11AFEDED7494A" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659750371822%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'03aa817f-1f2a-40f2-92a2-8c2a7c640966', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Web.HttpException', N'System.Web.Mvc', N'The controller for path ''/Client/GetClientList'' was not found or does not implement IController.', N'', 404, CAST(0x0000AEE8012176BF AS DateTime), 8620, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Web.HttpException"
  message="The controller for path ''/Client/GetClientList'' was not found or does not implement IController."
  source="System.Web.Mvc"
  detail="System.Web.HttpException (0x80004005): The controller for path ''/Client/GetClientList'' was not found or does not implement IController.&#xD;&#xA;   at System.Web.Mvc.DefaultControllerFactory.GetControllerInstance(RequestContext requestContext, Type controllerType)&#xD;&#xA;   at System.Web.Mvc.DefaultControllerFactory.CreateController(RequestContext requestContext, String controllerName)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.ProcessRequestInit(HttpContextBase httpContext, IController&amp; controller, IControllerFactory&amp; factory)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.BeginProcessRequest(HttpContextBase httpContext, AsyncCallback callback, Object state)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  time="2022-08-05T17:33:54.3431765Z"
  statusCode="404">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:application/json, text/javascript, */*; q=0.01&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;.Not/A)Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;103&quot;, &quot;Chromium&quot;;v=&quot;103&quot;&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_ORIGIN:https://padhshala.com&#xD;&#xA;HTTP_SEC_FETCH_SITE:cross-site&#xD;&#xA;HTTP_SEC_FETCH_MODE:cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:empty&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: application/json, text/javascript, */*; q=0.01&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Host: localhost:5002&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;.Not/A)Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;103&quot;, &quot;Chromium&quot;;v=&quot;103&quot;&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Origin: https://padhshala.com&#xD;&#xA;Sec-Fetch-Site: cross-site&#xD;&#xA;Sec-Fetch-Mode: cors&#xD;&#xA;Sec-Fetch-Dest: empty&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Client/GetClientList" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Client\GetClientList" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="14363" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Client/GetClientList" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Client/GetClientList" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="application/json, text/javascript, */*; q=0.01" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;.Not/A)Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;103&quot;, &quot;Chromium&quot;;v=&quot;103&quot;" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_ORIGIN">
      <value
        string="https://padhshala.com" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="cross-site" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="empty" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="ASP.NET_SessionId">
      <value
        string="gg3wqdyiuitt23353qwt33xy" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'22b61844-ecbc-4e12-a5f6-950b18c0d0b7', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Web.HttpException', N'System.Web.Mvc', N'The controller for path ''/Photos/Categories/""'' was not found or does not implement IController.', N'admin', 404, CAST(0x0000AEE90022A579 AS DateTime), 8640, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Web.HttpException"
  message="The controller for path ''/Photos/Categories/&quot;&quot;'' was not found or does not implement IController."
  source="System.Web.Mvc"
  detail="System.Web.HttpException (0x80004005): The controller for path ''/Photos/Categories/&quot;&quot;'' was not found or does not implement IController.&#xD;&#xA;   at System.Web.Mvc.DefaultControllerFactory.GetControllerInstance(RequestContext requestContext, Type controllerType)&#xD;&#xA;   at System.Web.Mvc.DefaultControllerFactory.CreateController(RequestContext requestContext, String controllerName)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.ProcessRequestInit(HttpContextBase httpContext, IController&amp; controller, IControllerFactory&amp; factory)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.BeginProcessRequest(HttpContextBase httpContext, AsyncCallback callback, Object state)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T02:06:08.6169858Z"
  statusCode="404">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=CEAD976AE1F932AF64B0F823D28687C6EF8DFC7BD6BF0CDD1CA9708E18302911C777BCF427A735C791C1BAB44BBAAC64F6DE8A323D17385F34F5BA4DD96C68531781A75D910D7C937A577E93FA4A8B970D9FA9D09C2D089D9139D093271D6607; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659751564895%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Category/CategoryPhoto?catId=186&amp;catName=Baby%20Foods&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:no-cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:image&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=CEAD976AE1F932AF64B0F823D28687C6EF8DFC7BD6BF0CDD1CA9708E18302911C777BCF427A735C791C1BAB44BBAAC64F6DE8A323D17385F34F5BA4DD96C68531781A75D910D7C937A577E93FA4A8B970D9FA9D09C2D089D9139D093271D6607; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659751564895%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Category/CategoryPhoto?catId=186&amp;catName=Baby%20Foods&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: no-cors&#xD;&#xA;Sec-Fetch-Dest: image&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Photos/Categories/&quot;&quot;" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Photos\Categories\&quot;&quot;" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16729" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Photos/Categories/&quot;&quot;" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Photos/Categories/&quot;&quot;" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=CEAD976AE1F932AF64B0F823D28687C6EF8DFC7BD6BF0CDD1CA9708E18302911C777BCF427A735C791C1BAB44BBAAC64F6DE8A323D17385F34F5BA4DD96C68531781A75D910D7C937A577E93FA4A8B970D9FA9D09C2D089D9139D093271D6607; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659751564895%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Category/CategoryPhoto?catId=186&amp;catName=Baby%20Foods" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="no-cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="image" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="CEAD976AE1F932AF64B0F823D28687C6EF8DFC7BD6BF0CDD1CA9708E18302911C777BCF427A735C791C1BAB44BBAAC64F6DE8A323D17385F34F5BA4DD96C68531781A75D910D7C937A577E93FA4A8B970D9FA9D09C2D089D9139D093271D6607" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659751564895%7D" />
    </item>
  </cookies>
</error>')
INSERT [dbo].[ELMAH_Error] ([ErrorId], [Application], [Host], [Type], [Source], [Message], [User], [StatusCode], [TimeUtc], [Sequence], [AllXml]) VALUES (N'2b908e84-221c-45ce-9f88-db2fafff9dcd', N'/LM/W3SVC/2/ROOT', N'LENOVO-PC', N'System.Web.HttpException', N'System.Web.Mvc', N'The controller for path ''/Photos/Categories/""'' was not found or does not implement IController.', N'admin', 404, CAST(0x0000AEE90022AF2C AS DateTime), 8641, N'<error
  application="/LM/W3SVC/2/ROOT"
  host="LENOVO-PC"
  type="System.Web.HttpException"
  message="The controller for path ''/Photos/Categories/&quot;&quot;'' was not found or does not implement IController."
  source="System.Web.Mvc"
  detail="System.Web.HttpException (0x80004005): The controller for path ''/Photos/Categories/&quot;&quot;'' was not found or does not implement IController.&#xD;&#xA;   at System.Web.Mvc.DefaultControllerFactory.GetControllerInstance(RequestContext requestContext, Type controllerType)&#xD;&#xA;   at System.Web.Mvc.DefaultControllerFactory.CreateController(RequestContext requestContext, String controllerName)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.ProcessRequestInit(HttpContextBase httpContext, IController&amp; controller, IControllerFactory&amp; factory)&#xD;&#xA;   at System.Web.Mvc.MvcHandler.BeginProcessRequest(HttpContextBase httpContext, AsyncCallback callback, Object state)&#xD;&#xA;   at System.Web.HttpApplication.CallHandlerExecutionStep.System.Web.HttpApplication.IExecutionStep.Execute()&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStepImpl(IExecutionStep step)&#xD;&#xA;   at System.Web.HttpApplication.ExecuteStep(IExecutionStep step, Boolean&amp; completedSynchronously)"
  user="admin"
  time="2022-08-06T02:06:16.8917263Z"
  statusCode="404">
  <serverVariables>
    <item
      name="ALL_HTTP">
      <value
        string="HTTP_CONNECTION:keep-alive&#xD;&#xA;HTTP_ACCEPT:image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8&#xD;&#xA;HTTP_ACCEPT_ENCODING:gzip, deflate, br&#xD;&#xA;HTTP_ACCEPT_LANGUAGE:en-US,en;q=0.9&#xD;&#xA;HTTP_COOKIE:_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=CEAD976AE1F932AF64B0F823D28687C6EF8DFC7BD6BF0CDD1CA9708E18302911C777BCF427A735C791C1BAB44BBAAC64F6DE8A323D17385F34F5BA4DD96C68531781A75D910D7C937A577E93FA4A8B970D9FA9D09C2D089D9139D093271D6607; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659751569146%7D&#xD;&#xA;HTTP_HOST:localhost:5002&#xD;&#xA;HTTP_REFERER:http://localhost:5002/Category/CategoryPhoto?catId=186&amp;catName=Baby%20Foods&#xD;&#xA;HTTP_USER_AGENT:Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;HTTP_SEC_CH_UA:&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;HTTP_SEC_CH_UA_MOBILE:?0&#xD;&#xA;HTTP_SEC_CH_UA_PLATFORM:&quot;Windows&quot;&#xD;&#xA;HTTP_SEC_FETCH_SITE:same-origin&#xD;&#xA;HTTP_SEC_FETCH_MODE:no-cors&#xD;&#xA;HTTP_SEC_FETCH_DEST:image&#xD;&#xA;" />
    </item>
    <item
      name="ALL_RAW">
      <value
        string="Connection: keep-alive&#xD;&#xA;Accept: image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8&#xD;&#xA;Accept-Encoding: gzip, deflate, br&#xD;&#xA;Accept-Language: en-US,en;q=0.9&#xD;&#xA;Cookie: _ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=CEAD976AE1F932AF64B0F823D28687C6EF8DFC7BD6BF0CDD1CA9708E18302911C777BCF427A735C791C1BAB44BBAAC64F6DE8A323D17385F34F5BA4DD96C68531781A75D910D7C937A577E93FA4A8B970D9FA9D09C2D089D9139D093271D6607; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659751569146%7D&#xD;&#xA;Host: localhost:5002&#xD;&#xA;Referer: http://localhost:5002/Category/CategoryPhoto?catId=186&amp;catName=Baby%20Foods&#xD;&#xA;User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36&#xD;&#xA;sec-ch-ua: &quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;&#xD;&#xA;sec-ch-ua-mobile: ?0&#xD;&#xA;sec-ch-ua-platform: &quot;Windows&quot;&#xD;&#xA;Sec-Fetch-Site: same-origin&#xD;&#xA;Sec-Fetch-Mode: no-cors&#xD;&#xA;Sec-Fetch-Dest: image&#xD;&#xA;" />
    </item>
    <item
      name="APPL_MD_PATH">
      <value
        string="/LM/W3SVC/2/ROOT" />
    </item>
    <item
      name="APPL_PHYSICAL_PATH">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\" />
    </item>
    <item
      name="AUTH_TYPE">
      <value
        string="Forms" />
    </item>
    <item
      name="AUTH_USER">
      <value
        string="admin" />
    </item>
    <item
      name="AUTH_PASSWORD">
      <value
        string="*****" />
    </item>
    <item
      name="LOGON_USER">
      <value
        string="admin" />
    </item>
    <item
      name="REMOTE_USER">
      <value
        string="admin" />
    </item>
    <item
      name="CERT_COOKIE">
      <value
        string="" />
    </item>
    <item
      name="CERT_FLAGS">
      <value
        string="" />
    </item>
    <item
      name="CERT_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERIALNUMBER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="CERT_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CERT_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="CONTENT_LENGTH">
      <value
        string="0" />
    </item>
    <item
      name="CONTENT_TYPE">
      <value
        string="" />
    </item>
    <item
      name="GATEWAY_INTERFACE">
      <value
        string="CGI/1.1" />
    </item>
    <item
      name="HTTPS">
      <value
        string="off" />
    </item>
    <item
      name="HTTPS_KEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SECRETKEYSIZE">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_ISSUER">
      <value
        string="" />
    </item>
    <item
      name="HTTPS_SERVER_SUBJECT">
      <value
        string="" />
    </item>
    <item
      name="INSTANCE_ID">
      <value
        string="2" />
    </item>
    <item
      name="INSTANCE_META_PATH">
      <value
        string="/LM/W3SVC/2" />
    </item>
    <item
      name="LOCAL_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="PATH_INFO">
      <value
        string="/Photos/Categories/&quot;&quot;" />
    </item>
    <item
      name="PATH_TRANSLATED">
      <value
        string="D:\Projects\Git\MyTemplates\ECommerce\Application.Web\Photos\Categories\&quot;&quot;" />
    </item>
    <item
      name="QUERY_STRING">
      <value
        string="" />
    </item>
    <item
      name="REMOTE_ADDR">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_HOST">
      <value
        string="::1" />
    </item>
    <item
      name="REMOTE_PORT">
      <value
        string="16730" />
    </item>
    <item
      name="REQUEST_METHOD">
      <value
        string="GET" />
    </item>
    <item
      name="SCRIPT_NAME">
      <value
        string="/Photos/Categories/&quot;&quot;" />
    </item>
    <item
      name="SERVER_NAME">
      <value
        string="localhost" />
    </item>
    <item
      name="SERVER_PORT">
      <value
        string="5002" />
    </item>
    <item
      name="SERVER_PORT_SECURE">
      <value
        string="0" />
    </item>
    <item
      name="SERVER_PROTOCOL">
      <value
        string="HTTP/1.1" />
    </item>
    <item
      name="SERVER_SOFTWARE">
      <value
        string="Microsoft-IIS/10.0" />
    </item>
    <item
      name="URL">
      <value
        string="/Photos/Categories/&quot;&quot;" />
    </item>
    <item
      name="HTTP_CONNECTION">
      <value
        string="keep-alive" />
    </item>
    <item
      name="HTTP_ACCEPT">
      <value
        string="image/avif,image/webp,image/apng,image/svg+xml,image/*,*/*;q=0.8" />
    </item>
    <item
      name="HTTP_ACCEPT_ENCODING">
      <value
        string="gzip, deflate, br" />
    </item>
    <item
      name="HTTP_ACCEPT_LANGUAGE">
      <value
        string="en-US,en;q=0.9" />
    </item>
    <item
      name="HTTP_COOKIE">
      <value
        string="_ga=GA1.1.114461141.1637164918; style=null; ASP.NET_SessionId=3f43bml03fllgg5ldhreasgq; .ASPXAUTH=CEAD976AE1F932AF64B0F823D28687C6EF8DFC7BD6BF0CDD1CA9708E18302911C777BCF427A735C791C1BAB44BBAAC64F6DE8A323D17385F34F5BA4DD96C68531781A75D910D7C937A577E93FA4A8B970D9FA9D09C2D089D9139D093271D6607; TawkConnectionTime=0; twk_uuid_5ef15d3d4a7c6258179b24cf=%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659751569146%7D" />
    </item>
    <item
      name="HTTP_HOST">
      <value
        string="localhost:5002" />
    </item>
    <item
      name="HTTP_REFERER">
      <value
        string="http://localhost:5002/Category/CategoryPhoto?catId=186&amp;catName=Baby%20Foods" />
    </item>
    <item
      name="HTTP_USER_AGENT">
      <value
        string="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36" />
    </item>
    <item
      name="HTTP_SEC_CH_UA">
      <value
        string="&quot;Chromium&quot;;v=&quot;104&quot;, &quot; Not A;Brand&quot;;v=&quot;99&quot;, &quot;Google Chrome&quot;;v=&quot;104&quot;" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_MOBILE">
      <value
        string="?0" />
    </item>
    <item
      name="HTTP_SEC_CH_UA_PLATFORM">
      <value
        string="&quot;Windows&quot;" />
    </item>
    <item
      name="HTTP_SEC_FETCH_SITE">
      <value
        string="same-origin" />
    </item>
    <item
      name="HTTP_SEC_FETCH_MODE">
      <value
        string="no-cors" />
    </item>
    <item
      name="HTTP_SEC_FETCH_DEST">
      <value
        string="image" />
    </item>
  </serverVariables>
  <cookies>
    <item
      name="_ga">
      <value
        string="GA1.1.114461141.1637164918" />
    </item>
    <item
      name="style">
      <value
        string="null" />
    </item>
    <item
      name="ASP.NET_SessionId">
      <value
        string="3f43bml03fllgg5ldhreasgq" />
    </item>
    <item
      name=".ASPXAUTH">
      <value
        string="CEAD976AE1F932AF64B0F823D28687C6EF8DFC7BD6BF0CDD1CA9708E18302911C777BCF427A735C791C1BAB44BBAAC64F6DE8A323D17385F34F5BA4DD96C68531781A75D910D7C937A577E93FA4A8B970D9FA9D09C2D089D9139D093271D6607" />
    </item>
    <item
      name="TawkConnectionTime">
      <value
        string="0" />
    </item>
    <item
      name="twk_uuid_5ef15d3d4a7c6258179b24cf">
      <value
        string="%7B%22uuid%22%3A%221.AGE4gpIbL4dP8M5xhihdF59gwDVAVflwRs9TbN7LcDd9yubpt6XPWoSa2mMqkilJ42SqKTt4XROEuaJTF4gvTRuMW9R5rAmqB55XrEQF9tgiHTFQjqqVz7248NcY25mL%22%2C%22version%22%3A3%2C%22domain%22%3Anull%2C%22ts%22%3A1659751569146%7D" />
    </item>
  </cookies>
</error>')
SET IDENTITY_INSERT [dbo].[ELMAH_Error] OFF
SET IDENTITY_INSERT [dbo].[ItemTypes] ON 

INSERT [dbo].[ItemTypes] ([Id], [Name]) VALUES (1, N'DRY')
INSERT [dbo].[ItemTypes] ([Id], [Name]) VALUES (2, N'FROZEN')
INSERT [dbo].[ItemTypes] ([Id], [Name]) VALUES (21, N'N/A')
SET IDENTITY_INSERT [dbo].[ItemTypes] OFF
INSERT [dbo].[OrderItems] ([Id], [OrderId], [ProductId], [Quantity], [Discount], [Price], [TotalPrice], [ImageUrl], [ActionDate], [Title], [CostPrice]) VALUES (N'131fcce8-2073-46c1-8a91-cb2075d5a038', N'24bd542a-f95c-4cc1-83f1-390342aa78cb', N'16467430-f031-4f7b-9f13-ad0776080b66', 1, CAST(0.00 AS Decimal(18, 2)), CAST(8.00 AS Decimal(18, 2)), CAST(8.00 AS Decimal(18, 2)), N'http://localhost:5002/ProductImages/Grid/8b081ebc-100c-43e9-a455-536511b42dd5.jpg', CAST(0x0000AEDD00F9F75F AS DateTime), NULL, CAST(5.00 AS Decimal(18, 2)))
INSERT [dbo].[OrderItems] ([Id], [OrderId], [ProductId], [Quantity], [Discount], [Price], [TotalPrice], [ImageUrl], [ActionDate], [Title], [CostPrice]) VALUES (N'1d89fd64-ee6b-4e90-be83-b194ff8be667', N'24bd542a-f95c-4cc1-83f1-390342aa78cb', N'daeb1bea-ac5c-402f-81d7-9d2eb8fb51fc', 1, CAST(0.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), N'http://localhost:5002/ProductImages/Grid/353ce4d3-a709-4a61-af6c-a2366580834e.jpg', CAST(0x0000AEDD00F9F757 AS DateTime), NULL, CAST(3.00 AS Decimal(18, 2)))
INSERT [dbo].[OrderItems] ([Id], [OrderId], [ProductId], [Quantity], [Discount], [Price], [TotalPrice], [ImageUrl], [ActionDate], [Title], [CostPrice]) VALUES (N'37a2b0d2-87b4-40aa-af31-266743573341', N'b0dec7d1-9d49-4344-ba81-8c75b53dce17', N'83264cc0-6d17-4ea3-94fd-bf41b4cff20c', 1, CAST(0.00 AS Decimal(18, 2)), CAST(24.00 AS Decimal(18, 2)), CAST(24.00 AS Decimal(18, 2)), N'http://localhost:5002/ProductImages/Grid/00174388-0014-450e-a7c3-6303237a2647.jpg', CAST(0x0000AEDE00B7BE07 AS DateTime), NULL, CAST(21.00 AS Decimal(18, 2)))
INSERT [dbo].[OrderItems] ([Id], [OrderId], [ProductId], [Quantity], [Discount], [Price], [TotalPrice], [ImageUrl], [ActionDate], [Title], [CostPrice]) VALUES (N'3e22cc05-e99e-49f2-ab0d-8058926619e8', N'f8869f41-d049-43e3-a094-3e97f83fe835', N'f9574043-800c-4c31-b1bc-8d5396b96636', 1, CAST(0.00 AS Decimal(18, 2)), CAST(23.00 AS Decimal(18, 2)), CAST(23.00 AS Decimal(18, 2)), N'http://localhost:5002/ProductImages/Grid/3b46f57a-106f-4c24-88d6-25ea254f3048.jpg', CAST(0x0000AEDE00B7EDE8 AS DateTime), NULL, CAST(20.00 AS Decimal(18, 2)))
INSERT [dbo].[OrderItems] ([Id], [OrderId], [ProductId], [Quantity], [Discount], [Price], [TotalPrice], [ImageUrl], [ActionDate], [Title], [CostPrice]) VALUES (N'95fa2719-ef06-471e-adac-1a17b9928289', N'b0dec7d1-9d49-4344-ba81-8c75b53dce17', N'daeb1bea-ac5c-402f-81d7-9d2eb8fb51fc', 1, CAST(0.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), N'http://localhost:5002/ProductImages/Grid/353ce4d3-a709-4a61-af6c-a2366580834e.jpg', CAST(0x0000AEDE00B7BDFA AS DateTime), NULL, CAST(3.00 AS Decimal(18, 2)))
INSERT [dbo].[OrderItems] ([Id], [OrderId], [ProductId], [Quantity], [Discount], [Price], [TotalPrice], [ImageUrl], [ActionDate], [Title], [CostPrice]) VALUES (N'ac26875a-db08-467e-9333-3667383ebe16', N'f8869f41-d049-43e3-a094-3e97f83fe835', N'16467430-f031-4f7b-9f13-ad0776080b66', 1, CAST(0.00 AS Decimal(18, 2)), CAST(6.00 AS Decimal(18, 2)), CAST(6.00 AS Decimal(18, 2)), N'http://localhost:5002/ProductImages/Grid/8b081ebc-100c-43e9-a455-536511b42dd5.jpg', CAST(0x0000AEDE00B7EDE7 AS DateTime), NULL, CAST(5.00 AS Decimal(18, 2)))
INSERT [dbo].[OrderItems] ([Id], [OrderId], [ProductId], [Quantity], [Discount], [Price], [TotalPrice], [ImageUrl], [ActionDate], [Title], [CostPrice]) VALUES (N'c7a1159f-d8c5-4f22-a9b2-41f451fb5c05', N'6c8d7a3d-a5cd-4810-b075-21a6bbf959ff', N'329a702a-3b6a-4452-92ae-350e3135f292', 1, CAST(0.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), CAST(10.00 AS Decimal(18, 2)), N'http://localhost:5002/ProductImages/Grid/8d2000b5-1b40-417d-8db7-6201a5828c9b.jpg', CAST(0x0000AEDE00B7D83A AS DateTime), NULL, CAST(8.00 AS Decimal(18, 2)))
INSERT [dbo].[OrderItems] ([Id], [OrderId], [ProductId], [Quantity], [Discount], [Price], [TotalPrice], [ImageUrl], [ActionDate], [Title], [CostPrice]) VALUES (N'ccfb4275-f7e2-4743-a8d0-4028d2c1dbe5', N'6c8d7a3d-a5cd-4810-b075-21a6bbf959ff', N'e9adbbca-47af-4d76-9127-88fac1fde860', 1, CAST(0.00 AS Decimal(18, 2)), CAST(32.00 AS Decimal(18, 2)), CAST(32.00 AS Decimal(18, 2)), N'http://localhost:5002/ProductImages/Grid/cafdda9f-83e2-423d-aede-12c41619ef4a.jpg', CAST(0x0000AEDE00B7D83B AS DateTime), NULL, CAST(28.00 AS Decimal(18, 2)))
INSERT [dbo].[OrderItems] ([Id], [OrderId], [ProductId], [Quantity], [Discount], [Price], [TotalPrice], [ImageUrl], [ActionDate], [Title], [CostPrice]) VALUES (N'e7e53976-a4ca-410f-9ce0-9781b89a21fa', N'24bd542a-f95c-4cc1-83f1-390342aa78cb', N'83264cc0-6d17-4ea3-94fd-bf41b4cff20c', 1, CAST(0.00 AS Decimal(18, 2)), CAST(24.00 AS Decimal(18, 2)), CAST(24.00 AS Decimal(18, 2)), N'http://localhost:5002/ProductImages/Grid/00174388-0014-450e-a7c3-6303237a2647.jpg', CAST(0x0000AEDD00F9F75E AS DateTime), NULL, CAST(21.00 AS Decimal(18, 2)))
INSERT [dbo].[OrderItems] ([Id], [OrderId], [ProductId], [Quantity], [Discount], [Price], [TotalPrice], [ImageUrl], [ActionDate], [Title], [CostPrice]) VALUES (N'fa7b4a04-105c-4004-800e-e9d940174a10', N'6c8d7a3d-a5cd-4810-b075-21a6bbf959ff', N'649aac19-4e05-4dc6-8c70-f4d2c9b2267f', 1, CAST(0.00 AS Decimal(18, 2)), CAST(6.00 AS Decimal(18, 2)), CAST(6.00 AS Decimal(18, 2)), N'http://localhost:5002/ProductImages/Grid/e2db4744-f0a1-478d-b106-2261a5187c72.jpg', CAST(0x0000AEDE00B7D83B AS DateTime), NULL, CAST(4.00 AS Decimal(18, 2)))
INSERT [dbo].[Orders] ([Id], [UserId], [OrderCode], [Barcode], [PayAmount], [DueAmount], [Discount], [Vat], [ShippingAmount], [ReceiveAmount], [ChangeAmount], [OrderMode], [OrderStatus], [PaymentStatus], [PaymentType], [ActionDate], [ActionBy], [BranchId], [DeliveryDate], [DeliveryTime], [TotalWeight], [IsFrozen]) VALUES (N'24bd542a-f95c-4cc1-83f1-390342aa78cb', N'51c57015-1c02-4751-b68d-516882b9a901', N'637943586059437284', NULL, CAST(41.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(4.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, N'Online', N'Processing', N'Pending', N'COD', CAST(0x0000AEDD00F9F757 AS DateTime), N'Rezuanul ', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Orders] ([Id], [UserId], [OrderCode], [Barcode], [PayAmount], [DueAmount], [Discount], [Vat], [ShippingAmount], [ReceiveAmount], [ChangeAmount], [OrderMode], [OrderStatus], [PaymentStatus], [PaymentType], [ActionDate], [ActionBy], [BranchId], [DeliveryDate], [DeliveryTime], [TotalWeight], [IsFrozen]) VALUES (N'6c8d7a3d-a5cd-4810-b075-21a6bbf959ff', N'51c57015-1c02-4751-b68d-516882b9a901', N'637944305614730883', NULL, CAST(53.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(5.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, N'Online', N'Processing', N'Pending', N'COD', CAST(0x0000AEDE00B7D83A AS DateTime), N'Rezuanul ', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Orders] ([Id], [UserId], [OrderCode], [Barcode], [PayAmount], [DueAmount], [Discount], [Vat], [ShippingAmount], [ReceiveAmount], [ChangeAmount], [OrderMode], [OrderStatus], [PaymentStatus], [PaymentType], [ActionDate], [ActionBy], [BranchId], [DeliveryDate], [DeliveryTime], [TotalWeight], [IsFrozen]) VALUES (N'b0dec7d1-9d49-4344-ba81-8c75b53dce17', N'51c57015-1c02-4751-b68d-516882b9a901', N'637944305390729828', NULL, CAST(32.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(3.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, N'Online', N'Processing', N'Pending', N'COD', CAST(0x0000AEDE00B7BDFA AS DateTime), N'Rezuanul ', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Orders] ([Id], [UserId], [OrderCode], [Barcode], [PayAmount], [DueAmount], [Discount], [Vat], [ShippingAmount], [ReceiveAmount], [ChangeAmount], [OrderMode], [OrderStatus], [PaymentStatus], [PaymentType], [ActionDate], [ActionBy], [BranchId], [DeliveryDate], [DeliveryTime], [TotalWeight], [IsFrozen]) VALUES (N'f8869f41-d049-43e3-a094-3e97f83fe835', N'51c57015-1c02-4751-b68d-516882b9a901', N'637944305799703849', NULL, CAST(32.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), CAST(3.00 AS Decimal(18, 2)), CAST(0.00 AS Decimal(18, 2)), NULL, NULL, N'Online', N'Processing', N'Pending', N'COD', CAST(0x0000AEDE00B7EDE7 AS DateTime), N'Rezuanul ', NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'0657830b-7538-41c9-834a-ed3ee2ceb688', N'37e56e8f-de2f-4cd5-b40b-bb5d041897e8', N'fd42283a-7b09-4be9-b510-fc6925cda931.jpg', 1, 1, 1, CAST(0x0000AEDD00BB8F1D AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'10353679-5acf-49eb-a3d5-a23ac6638c19', N'f8dacad6-b02f-4582-adeb-797ef2111312', N'5da7b065-d7fb-42df-9418-dd0af41742f3.jpg', 1, 1, 1, CAST(0x0000AEDD00A205BE AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'10dc18c1-100f-4d21-b96e-688d31a16398', N'83264cc0-6d17-4ea3-94fd-bf41b4cff20c', N'7db8af27-c326-4bf6-88ed-f13ed5a2b089.jpg', 2, 0, 1, CAST(0x0000AEDD00E964B0 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'125a5a09-ce88-4429-ae8d-f8d91bba7930', N'329a702a-3b6a-4452-92ae-350e3135f292', N'8d2000b5-1b40-417d-8db7-6201a5828c9b.jpg', 1, 1, 1, CAST(0x0000AEDD0097708D AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'260dad09-9247-41e9-81e9-378e2277a49f', N'daeb1bea-ac5c-402f-81d7-9d2eb8fb51fc', N'353ce4d3-a709-4a61-af6c-a2366580834e.jpg', 1, 1, 1, CAST(0x0000AEDD00BBC7E2 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'3fa077c6-0718-41ec-8813-1d97685e706e', N'83264cc0-6d17-4ea3-94fd-bf41b4cff20c', N'00174388-0014-450e-a7c3-6303237a2647.jpg', 1, 1, 1, CAST(0x0000AEDD00E9647D AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'41c46a9a-02fd-4f59-8416-ecde10704f97', N'f8dacad6-b02f-4582-adeb-797ef2111312', N'42b273ca-aa9c-4087-b945-29551c79a722.jpg', 2, 0, 1, CAST(0x0000AEDD00A20665 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'45072d01-ac6f-463b-8b8f-39f2cc4576d1', N'd6f0c790-8e6e-47e7-b01f-29f02f4c9c8b', N'3f1b022e-33a2-45ff-859f-765b21657d1d.jpg', 1, 1, 1, CAST(0x0000AEDD00BBFD04 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'4bd53699-a0f6-4d73-9a49-0a17bf038194', N'720eca96-7e4b-4937-956c-ebae0ae8a08f', N'5b13493e-a392-4f8a-8deb-623be50cdc42.jpg', 1, 1, 1, CAST(0x0000AEDD00EB33E0 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'52ea9b95-0a03-420e-9f3f-5199a1eff069', N'8a02fef9-914f-44b1-adac-77a0eb58d031', N'113ac605-76d0-4fdc-bb4a-4c88f999f4bc.jpg', 2, 0, 1, CAST(0x0000AEDD00A5A4B5 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'5369f04e-d8ad-4eb2-b84e-ec33a5fb71ae', N'5b43c8db-f267-4679-898e-731770afd449', N'1e1e6c67-a074-420e-a6d6-0fb186a3c999.jpg', 2, 0, 1, CAST(0x0000AEDD0095384E AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'55ad6deb-8393-4d1f-ad00-cc718c88399e', N'd689d246-0b58-49a2-9afc-63ccd1904295', N'8f59649b-fae5-42f5-be49-92c3d9b12ab4.jpg', 1, 1, 1, CAST(0x0000AEDD00E99A46 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'55d4cb25-267f-459e-a44e-0b9b65f9fa0b', N'e55c6296-d187-40cb-a7f4-125b2ecf5bfe', N'e4c97c4c-d649-484a-83be-7ca1b239edc7.jpg', 1, 1, 1, CAST(0x0000AEDD00E8AD10 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'5c56b90c-2345-4b81-b768-976bd813ccc4', N'2396724d-401c-4781-9a1c-f17966927509', N'0f155dd9-3ebb-4a7e-a4b4-e431411ab5de.jpg', 1, 1, 1, CAST(0x0000AEDD00ED8A25 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'5cf3366d-41c0-4293-9615-a3ae46742c40', N'3461e98e-e3ba-4f19-a33c-5cf2e5cd2579', N'6b2ad92e-ec3f-403b-9560-4bb042387db9.jpg', 1, 1, 1, CAST(0x0000AEDD00998F4D AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'5e614f24-1da0-4ce6-90de-a70499dec2ad', N'dbbae2be-0b82-450f-8628-8467fc9a53ba', N'93a7d561-83c0-43fa-80ea-f189daaa1f59.jpg', 2, 0, 1, CAST(0x0000AEDD00BD4A09 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'6262379e-13de-4e2a-8796-6ef211b56887', N'd54151b8-1e04-446e-b0ba-2258059e445f', N'8634bcdd-b478-4f0a-b681-5a34ca637f78.jpg', 2, 0, 1, CAST(0x0000AEDD00EABF45 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'659240a0-d7ae-4978-8e41-7d395da9fb78', N'16467430-f031-4f7b-9f13-ad0776080b66', N'50030365-c971-4a65-8d0b-47cf0bf1a15e.jpg', 2, 0, 1, CAST(0x0000AEDD00BD9892 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'69b7a75e-a079-4eda-b357-b3b800a4bc52', N'a4625244-33d1-4d26-9d94-b801c808a6e5', N'd651c746-39d1-47c9-9604-65496717c271.jpg', 1, 1, 1, CAST(0x0000AEDD00EC9A59 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'6a86a22c-fefe-42c2-bc99-f1c3baa771c2', N'33be86de-60e5-4bd3-9e2a-9711dcc8764a', N'ef1f6627-ce25-44a1-93ae-98bffd036d9a.jpg', 1, 1, 1, CAST(0x0000AEDD009A154F AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'6f40facf-aaf1-4040-bae0-d62ce2073b15', N'033197c3-29ca-4e20-855e-44dea8276478', N'71230a0d-6734-4eb4-9f20-77b5373b9921.jpg', 1, 1, 1, CAST(0x0000AEDD00F0EF97 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'6f910916-e55c-4760-8304-2b0375387103', N'35a35bcb-6ad8-4a42-a7b6-ce2f29491502', N'5d881793-67ea-435f-a505-3224b1546d7b.jpg', 1, 1, 1, CAST(0x0000AEDD00EDF676 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'6fe3cd65-cbce-4e3d-ba09-0254ba350296', N'3c344ce0-732c-41c8-afe6-ef1d312a203c', N'2ac27b6d-a394-4f24-91a8-40c9caa0dc3e.jpg', 1, 1, 1, CAST(0x0000AEDD00F05CD3 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'7186d666-8a8c-48da-b7c2-661ec0aef999', N'd54151b8-1e04-446e-b0ba-2258059e445f', N'5fb6d366-5f51-422e-9fa1-6911cb0ee155.jpg', 1, 1, 1, CAST(0x0000AEDD00EABF0C AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'7398613d-b95e-4098-ad5f-408e1b1d4425', N'f9574043-800c-4c31-b1bc-8d5396b96636', N'3b46f57a-106f-4c24-88d6-25ea254f3048.jpg', 1, 1, 1, CAST(0x0000AEDD00A4C20F AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'7c49496c-ac37-414d-9c9e-926a2d920b6d', N'649aac19-4e05-4dc6-8c70-f4d2c9b2267f', N'9fa5621a-65d0-41ec-8c3c-f311ff83e412.jpg', 2, 0, 1, CAST(0x0000AEDD00A77412 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'7d49de73-e0ab-4d1b-8dfb-0912b668c77c', N'dbbae2be-0b82-450f-8628-8467fc9a53ba', N'fdedabd8-b818-4d93-b170-c3f8dbbf6f0d.jpg', 1, 1, 1, CAST(0x0000AEDD00BD497E AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'7e2a6f64-053c-41b3-891b-f0ab9f00d133', N'5b43c8db-f267-4679-898e-731770afd449', N'474f3253-7b8d-4ce9-8db2-88ed06042117.jpg', 1, 1, 1, CAST(0x0000AEDD009537EE AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'7f10394f-9ee3-4ae1-87b5-b873101bd068', N'99d49753-4d4d-4a0c-98f4-f1a3f7d33884', N'bc6d00d6-4697-45ac-8bcb-a59cc71561e4.jpg', 1, 1, 1, CAST(0x0000AEDD00A2A602 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'91c8ac34-54ac-433f-a19c-2159f76648f3', N'e9adbbca-47af-4d76-9127-88fac1fde860', N'cafdda9f-83e2-423d-aede-12c41619ef4a.jpg', 1, 1, 1, CAST(0x0000AEDD00E851BB AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'96c53198-1fa5-47b5-b4a0-3887a858186a', N'a0ca6fc4-b9c0-41c1-a8a6-bf45e86f3d7f', N'5d2cad53-4063-4463-aad7-d6f3fe921043.jpg', 1, 1, 1, CAST(0x0000AEDD00ED0EF7 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'98eab334-5ddb-436e-ae6e-91fbaebaaf9a', N'0347c317-5f70-4ec0-9c82-4da8885e0098', N'456cd92e-c021-4f03-92d3-e635ec4a54e3.jpg', 1, 1, 1, CAST(0x0000AEDD0098F565 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'a479de15-eb07-4a55-a514-9b4cc66c9a2f', N'0347c317-5f70-4ec0-9c82-4da8885e0098', N'00c9c946-c32e-40b5-9181-dcaeb122c34c.jpg', 2, 0, 1, CAST(0x0000AEDD0098F5B2 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'a76da5e4-ec43-4f25-b5fc-4070800d4395', N'8a02fef9-914f-44b1-adac-77a0eb58d031', N'0beca51f-c5a8-4294-a5f9-7c1873978173.jpg', 1, 1, 1, CAST(0x0000AEDD00A5A45E AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'ac3d606a-1e9f-4491-b989-0ecec57054d7', N'9ca548a1-62ee-46e9-aa15-3a09ac0ce9e2', N'025dc788-2922-4568-b3b0-51628f31b6d4.jpg', 2, 0, 1, CAST(0x0000AEDD00A4051A AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'b639ed04-2e26-4a9b-9f8d-e2678df3a534', N'16467430-f031-4f7b-9f13-ad0776080b66', N'8b081ebc-100c-43e9-a455-536511b42dd5.jpg', 1, 1, 1, CAST(0x0000AEDD00BD9872 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'c20e0aaa-36d7-4dc8-b212-49d5e6838701', N'649aac19-4e05-4dc6-8c70-f4d2c9b2267f', N'e2db4744-f0a1-478d-b106-2261a5187c72.jpg', 1, 1, 1, CAST(0x0000AEDD00A773CB AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'c25ad6a5-ca17-45b5-b21e-9a5ea5957a0f', N'9fa42735-dae7-4c59-99ce-591d9a2dc6cb', N'358e7a74-26a5-41f9-aa15-4348d7620744.jpg', 1, 1, 1, CAST(0x0000AEDD00A928F3 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'c668121e-f21f-4242-bc26-daaae052844c', N'a4625244-33d1-4d26-9d94-b801c808a6e5', N'f9084bb6-9e78-4a1b-97fd-a7085588ac3e.jpg', 2, 0, 1, CAST(0x0000AEDD00EC9A83 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'c9709980-79e1-4866-8755-e43592bfb9b7', N'00ac9e01-a5d1-4c4d-8c73-b5c8c3380c28', N'a3751555-a244-489e-b1cf-0c7c502b6372.jpg', 1, 1, 1, CAST(0x0000AEDD00E7F371 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'd6a05c9c-b07f-4d07-bcf2-4a5928207f9e', N'35c0c330-e308-4f9f-8a7d-f8cf7fae5179', N'151e7dcc-34f5-437d-8a1c-cd2f8eafb1cd.jpg', 1, 1, 1, CAST(0x0000AEDD00EBC106 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'db9547e1-2897-474f-9a0b-17b4f0865711', N'2d075749-3810-443d-a6c6-b89234cececc', N'c43326fd-b1cd-4f54-8f52-0bb48ad74269.jpg', 1, 1, 1, CAST(0x0000AEDD00BC35DD AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'dd6b92fc-9e96-449d-9bb3-758bfbb09f5d', N'35c0c330-e308-4f9f-8a7d-f8cf7fae5179', N'bc97cfe1-bfad-4152-b804-c668c5c243a8.jpg', 2, 0, 1, CAST(0x0000AEDD00EBC135 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'ee4024d7-8556-4957-801a-630511d7aa9b', N'0c6c4953-903e-4253-baaf-ab460703abdf', N'520d33b2-1202-4aa7-9086-62497da38030.jpg', 1, 1, 1, CAST(0x0000AEDD009AE9EB AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'f13a53fa-4edd-428c-9db7-bbbbfd5475e1', N'9ca548a1-62ee-46e9-aa15-3a09ac0ce9e2', N'07c2c57d-448e-4759-b98d-f96c68a81334.jpg', 1, 1, 1, CAST(0x0000AEDD00A40494 AS DateTime))
INSERT [dbo].[ProductImages] ([Id], [ProductId], [ImageName], [DisplayOrder], [IsPrimaryImage], [IsApproved], [ActionDate]) VALUES (N'fba27da0-a508-4ec4-b758-5020ca4efda9', N'2d075749-3810-443d-a6c6-b89234cececc', N'45075052-9534-4010-9081-e2046d1f4fcb.jpg', 2, 0, 1, CAST(0x0000AEDD00BC35EE AS DateTime))
SET IDENTITY_INSERT [dbo].[Products] ON 

INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'00ac9e01-a5d1-4c4d-8c73-b5c8c3380c28', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 188, 4, 69, 21, 1058, N'BFI', N'010001010589', N'Baby Food Items', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 0, 20.0000, 25.0000, 7, CAST(1.00 AS Decimal(18, 2)), N'pc', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00E7F301 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 25.0000, 25.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'033197c3-29ca-4e20-855e-44dea8276478', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 182, 4, 69, 21, 1048, N'QCI', N'010001010489', N'Quality Carrot Items', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 0, 5.0000, 7.0000, 5, CAST(2.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, 1, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00A800CF AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 7.0000, 7.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'0347c317-5f70-4ec0-9c82-4da8885e0098', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 176, 4, 69, 2, 1038, N'FC', N'010001010389', N'Full Chicken', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.1500', 1, 5.0000, 8.0000, 1, CAST(0.00 AS Decimal(18, 2)), N'gm', NULL, NULL, 5, 1, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD0098F505 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 8.0000, 8.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'0c6c4953-903e-4253-baaf-ab460703abdf', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 179, 4, 69, 2, 1041, N'FsI', N'010001010419', N'Fish slice Item', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 6.0000, 12.0000, 1, CAST(1.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, 1, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD009AE94B AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 12.0000, 12.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'16467430-f031-4f7b-9f13-ad0776080b66', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 190, 4, 69, 21, 1057, N'OJI', N'010001010579', N'Orange Juice Item', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 5.0000, 8.0000, 18, CAST(1.00 AS Decimal(18, 2)), N'lt', NULL, NULL, 5, 3, 2, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDE00B65A02 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 8.0000, 8.0000, 2.0000, 2.0000, 2.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'2396724d-401c-4781-9a1c-f17966927509', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 198, 4, 69, NULL, 1068, N'RF', N'010001010689', N'Rice Flour', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 20.0000, 24.0000, 10, CAST(2.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, 2, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00EF0C44 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 24.0000, 24.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'2d075749-3810-443d-a6c6-b89234cececc', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 196, 4, 69, 21, 1055, N'SCI', N'010001010559', N'Sprint Can Items', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 0, 2.0000, 4.0000, 50, CAST(1.00 AS Decimal(18, 2)), N'lt', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00BC3564 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 4.0000, 4.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'329a702a-3b6a-4452-92ae-350e3135f292', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 175, 4, 69, 2, 1037, N'BPP1', N'010001010379', N'Beef Premium Pack 1kg', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 0, 8.0000, 10.0000, 0, CAST(1.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, 1, 1, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00977051 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 10.0000, 10.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'33be86de-60e5-4bd3-9e2a-9711dcc8764a', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 176, 4, 69, 2, 1040, N'FCM', N'010001010409', N'Frozen Chicken Meat', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 7.0000, 10.0000, 1, CAST(2.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, 5, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDE00B72240 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 10.0000, 10.0000, 3.0000, 3.0000, 3.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'3461e98e-e3ba-4f19-a33c-5cf2e5cd2579', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 176, 4, 69, 2, 1039, N'BCM', N'010001010399', N'Boiler Chicken Meat', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 10.0000, 12.0000, 1, CAST(2000.00 AS Decimal(18, 2)), N'gm', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00998EF6 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 12.0000, 12.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'35a35bcb-6ad8-4a42-a7b6-ce2f29491502', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 198, 4, 69, NULL, 1069, N'WRF', N'010001010699', N'White Rice Flour', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 10.0000, 12.0000, 10, CAST(1.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, 1, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00EE39F9 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 12.0000, 12.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'35c0c330-e308-4f9f-8a7d-f8cf7fae5179', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 197, 4, 69, NULL, 1065, N'TPI', N'010001010659', N'Taste Pinut Item', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 26.0000, 30.0000, 1, CAST(1000.00 AS Decimal(18, 2)), N'gm', NULL, NULL, 5, 4, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDE00B6E883 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 30.0000, 30.0000, 5.0000, 5.0000, 5.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'37e56e8f-de2f-4cd5-b40b-bb5d041897e8', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 196, 4, 69, 21, 1052, N'FSD', N'010001010529', N'Fanta Soft Drinks', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 4.0000, 9.0000, 20, CAST(1.00 AS Decimal(18, 2)), N'lt', NULL, NULL, 5, 1, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00BB8EE3 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 9.0000, 9.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'3c344ce0-732c-41c8-afe6-ef1d312a203c', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 182, 4, 69, 21, 1050, N'QC', N'010001010509_deleted_637943564653478222', N'Quality Carrots', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 0, 4.0000, 7.0000, 4, CAST(2000.00 AS Decimal(18, 2)), N'gm', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 1, N'Running', CAST(0x0000AEDD00A85708 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, N'_deleted_637943564653478222', 7.0000, 7.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'5b43c8db-f267-4679-898e-731770afd449', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 175, 4, 69, 2, 1036, N'BS', N'010001010369', N'Beef Steaks', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 10.0000, 12.0000, 1, CAST(1.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, 1, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD0095376D AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 12.0000, 12.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'5c6edc43-9967-412a-9326-d7fba4b72861', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 182, 4, 69, 21, 1049, N'QCI', N'010001010499_deleted_637943565891148355', N'Quality Carrot Items', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 0, 5.0000, 7.0000, 5, CAST(2.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 1, N'Running', CAST(0x0000AEDD00A81C2A AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, N'_deleted_637943565891148355', 7.0000, 7.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'649aac19-4e05-4dc6-8c70-f4d2c9b2267f', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 181, 4, 69, 21, 1047, N'EB', N'010001010479', N'European Banana', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 4.0000, 6.0000, 19, CAST(8.00 AS Decimal(18, 2)), N'pc', NULL, NULL, 5, NULL, 1, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00A77384 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 6.0000, 6.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'720eca96-7e4b-4937-956c-ebae0ae8a08f', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 197, 4, 69, NULL, 1064, N'PAT', N'010001010649', N'PINUTS AMEND TORRADO', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 0, 18.0000, 22.0000, 7, CAST(2000.00 AS Decimal(18, 2)), N'gm', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00EB33A9 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 22.0000, 22.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'83264cc0-6d17-4ea3-94fd-bf41b4cff20c', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 187, 4, 69, NULL, 1061, N'NBM', N'010001010619', N'Nido Baby Milk', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 21.0000, 24.0000, 6, CAST(1.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, 1, 2, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00EEE147 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 24.0000, 24.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'8a02fef9-914f-44b1-adac-77a0eb58d031', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 181, 4, 69, 21, 1046, N'GFL', N'010001010469', N'Garden Fresh Lemon', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 5.0000, 7.0000, 20, CAST(500.00 AS Decimal(18, 2)), N'gm', NULL, NULL, 5, 6, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00A5A3EB AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 7.0000, 7.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'99d49753-4d4d-4a0c-98f4-f1a3f7d33884', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 178, 4, 69, 2, 1043, N'CFI', N'010001010439', N'Canned Fish Item', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 15.0000, 18.0000, 5, CAST(1.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00A2A5B4 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 18.0000, 18.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'9ca548a1-62ee-46e9-aa15-3a09ac0ce9e2', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 181, 4, 69, 21, 1044, N'FGM', N'010001010449', N'Fresh Garden Mango', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 25.0000, 28.0000, 20, CAST(10.00 AS Decimal(18, 2)), N'pc', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00A403E7 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 28.0000, 28.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'9fa42735-dae7-4c59-99ce-591d9a2dc6cb', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 184, 4, 69, 21, 1051, N'PPB', N'010001010519', N'Pepperoni Pull-Apart Bread', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 5.0000, 6.0000, 10, CAST(1.00 AS Decimal(18, 2)), N'pc', NULL, NULL, 5, 1, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00A928AA AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 6.0000, 6.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'a0ca6fc4-b9c0-41c1-a8a6-bf45e86f3d7f', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 198, 4, 69, NULL, 1067, N'RSf', N'010001010679', N'Rice Substitute flour', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 12.0000, 15.0000, 8, CAST(1.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00ED0EB6 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 15.0000, 15.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'a4625244-33d1-4d26-9d94-b801c808a6e5', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 198, 4, 69, NULL, 1066, N'RP', N'010001010669', N'Rice Powder', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 5.0000, 7.0000, 5, CAST(1.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, 2, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00EE8E0E AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 7.0000, 7.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'd54151b8-1e04-446e-b0ba-2258059e445f', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 197, 4, 69, NULL, 1063, N'DN', N'010001010639', N'Delicious Nuts', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 0, 12.0000, 15.0000, 50, CAST(1000.00 AS Decimal(18, 2)), N'gm', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00EABEA1 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 15.0000, 15.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'd689d246-0b58-49a2-9afc-63ccd1904295', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 187, 4, 69, NULL, 1062, N'MCI', N'010001010629', N'Milk Canned Item', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 28.0000, 35.0000, 20, CAST(1000.00 AS Decimal(18, 2)), N'gm', NULL, NULL, 5, 4, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDE00B6203A AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 35.0000, 35.0000, 3.0000, 3.0000, 3.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'd6f0c790-8e6e-47e7-b01f-29f02f4c9c8b', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 196, 4, 69, 21, 1054, N'SSD', N'010001010549', N'Sprite Soft Drinks', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 0, 2.0000, 4.0000, 6, CAST(1.00 AS Decimal(18, 2)), N'lt', NULL, NULL, 5, 1, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00BBFCDC AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 4.0000, 4.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'daeb1bea-ac5c-402f-81d7-9d2eb8fb51fc', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 196, 4, 69, 21, 1053, N'FCI', N'010001010539', N'Fanta Can Item', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 3.0000, 5.0000, 6, CAST(1.00 AS Decimal(18, 2)), N'lt', NULL, NULL, 5, 1, 2, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00BBC7BA AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 5.0000, 5.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'dbbae2be-0b82-450f-8628-8467fc9a53ba', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 190, 4, 69, 21, 1056, N'TOJ', N'010001010569', N'Taste Orange Juice', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 5.0000, 7.0000, 20, CAST(2.00 AS Decimal(18, 2)), N'lt', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00BD4954 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 7.0000, 7.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'e55c6296-d187-40cb-a7f4-125b2ecf5bfe', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 188, 4, 69, NULL, 1060, N'BAJ', N'010001010609', N'Baby Apple Juice', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 0, 25.0000, 30.0000, 9, CAST(1.00 AS Decimal(18, 2)), N'lt', NULL, NULL, 5, NULL, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00E8ACA8 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 30.0000, 30.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'e9adbbca-47af-4d76-9127-88fac1fde860', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 188, 4, 69, 21, 1059, N'BMF', N'010001010599', N'Baby Mixed Fruits', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 28.0000, 32.0000, 6, CAST(1.00 AS Decimal(18, 2)), N'pc', NULL, NULL, 5, NULL, 1, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00E85124 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 32.0000, 32.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'f8dacad6-b02f-4582-adeb-797ef2111312', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 179, 4, 69, 2, 1042, N'SFI', N'010001010429', N'Sea Food Items', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 15.0000, 17.0000, 10, CAST(3.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, 1, NULL, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00A20528 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 1, NULL, 17.0000, 17.0000, 0.0000, 0.0000, 0.0000)
INSERT [dbo].[Products] ([Id], [UserId], [CategoryId], [BranchId], [SupplierId], [ItemTypeId], [Code], [ShortCode], [Barcode], [Title], [Description], [IsFeatured], [CostPrice], [RetailPrice], [Quantity], [Weight], [Unit], [IsDiscount], [DiscountType], [LowStockAlert], [ViewCount], [SoldCount], [ExpireDate], [IsInternal], [IsFastMoving], [IsMainItem], [IsApproved], [IsDeleted], [Status], [ActionDate], [IsSync], [Condition], [Color], [Capacity], [Manufacturer], [ModelNumber], [WarrantyPeriod], [IsFrozen], [IMEI], [WholesalePrice], [OnlinePrice], [RetailDiscount], [WholesaleDiscount], [OnlineDiscount]) VALUES (N'f9574043-800c-4c31-b1bc-8d5396b96636', N'99f048d1-d84e-4ea0-ae47-5726e155677e', 181, 4, 69, 21, 1045, N'FSF', N'010001010459', N'Fresh Strobery Foods', N'Lorem ipsum luctus convallis augue venenatis rutrum elementum, vitae taciti donec duis habitasse risus, adipiscing suspendisse torquent consequat proin hac erat hac molestie etiam condimentum tristique, lobortis est himenaeos semper donec, viverra at gravida ac.

Luctus phasellus pellentesque odio habitasse potenti duis nisl suspendisse platea elit nullam sem suscipit, consectetur sagittis sociosqu imperdiet morbi nibh rhoncus id porta posuere fames donec eu praesent vel condimentum libero pellentesque adipiscing posuere ultricies tristique ligula neque.

A mi ultrices elementum quam et pulvinar aliquam feugiat pellentesque, per pellentesque laoreet vehicula non rhoncus vulputate ut, lacinia elit nunc faucibus elementum tempus egestas in amet ultrices pretium vulputate erat etiam tortor rhoncus habitant risus himenaeos habitant massa interdum.', 1, 20.0000, 23.0000, 19, CAST(2.00 AS Decimal(18, 2)), N'kg', NULL, NULL, 5, NULL, 1, NULL, 0, 0, 0, 1, 0, N'Running', CAST(0x0000AEDD00A4C189 AS DateTime), 0, NULL, NULL, NULL, NULL, NULL, NULL, 0, NULL, 23.0000, 23.0000, 0.0000, 0.0000, 0.0000)
SET IDENTITY_INSERT [dbo].[Products] OFF
SET IDENTITY_INSERT [dbo].[Roles] ON 

INSERT [dbo].[Roles] ([Id], [Name]) VALUES (1, N'admin')
INSERT [dbo].[Roles] ([Id], [Name]) VALUES (2, N'manager')
INSERT [dbo].[Roles] ([Id], [Name]) VALUES (3, N'salesperson')
INSERT [dbo].[Roles] ([Id], [Name]) VALUES (4, N'customer')
SET IDENTITY_INSERT [dbo].[Roles] OFF
SET IDENTITY_INSERT [dbo].[Settings] ON 

INSERT [dbo].[Settings] ([Id], [Name], [Value]) VALUES (13, N'CompanyName', N'Grocery Shop')
INSERT [dbo].[Settings] ([Id], [Name], [Value]) VALUES (14, N'CompanyAddress', N'Your ecommerce location goes here')
INSERT [dbo].[Settings] ([Id], [Name], [Value]) VALUES (15, N'CompanyPhone', N'Tel: 0270-74-2258')
INSERT [dbo].[Settings] ([Id], [Name], [Value]) VALUES (16, N'CompanyEmail', N'info@ecommerce.com')
INSERT [dbo].[Settings] ([Id], [Name], [Value]) VALUES (17, N'Vat', N'8')
INSERT [dbo].[Settings] ([Id], [Name], [Value]) VALUES (22, N'CurrencySymbol', N'$')
SET IDENTITY_INSERT [dbo].[Settings] OFF
SET IDENTITY_INSERT [dbo].[SliderImages] ON 

INSERT [dbo].[SliderImages] ([Id], [ImageName], [DisplayOrder], [Url]) VALUES (8, N'968b490a-3f5d-4cbe-aa15-82347b77825e.jpg', 1, N'undefined')
INSERT [dbo].[SliderImages] ([Id], [ImageName], [DisplayOrder], [Url]) VALUES (9, N'a675f446-048a-4c69-a27b-b1b8009e1097.jpg', 2, N'undefined')
SET IDENTITY_INSERT [dbo].[SliderImages] OFF
SET IDENTITY_INSERT [dbo].[Suppliers] ON 

INSERT [dbo].[Suppliers] ([Id], [Name]) VALUES (69, N'Supplier-1')
SET IDENTITY_INSERT [dbo].[Suppliers] OFF
INSERT [dbo].[UserBranches] ([UserId], [BranchId]) VALUES (N'2000eb30-80ef-46e8-b7ff-6698f79dd057', 4)
INSERT [dbo].[UserBranches] ([UserId], [BranchId]) VALUES (N'99f048d1-d84e-4ea0-ae47-5726e155677e', 4)
INSERT [dbo].[UserBranches] ([UserId], [BranchId]) VALUES (N'66ceedef-763c-4f15-9a73-f1338c1aebee', 4)
INSERT [dbo].[UserBranches] ([UserId], [BranchId]) VALUES (N'4af3f626-add4-4cba-8bbd-e140a3bdd8be', 4)
INSERT [dbo].[UserBranches] ([UserId], [BranchId]) VALUES (N'fb502a0e-913f-4147-830e-67e0bda7413f', 4)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (N'2000eb30-80ef-46e8-b7ff-6698f79dd057', 2)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (N'99f048d1-d84e-4ea0-ae47-5726e155677e', 1)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (N'00000000-0000-0000-0000-000000000000', 4)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (N'66ceedef-763c-4f15-9a73-f1338c1aebee', 3)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (N'51c57015-1c02-4751-b68d-516882b9a901', 4)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (N'4af3f626-add4-4cba-8bbd-e140a3bdd8be', 1)
INSERT [dbo].[UserRoles] ([UserId], [RoleId]) VALUES (N'fb502a0e-913f-4147-830e-67e0bda7413f', 3)
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([Id], [Username], [Password], [FirstName], [LastName], [ShipAddress], [ShipZipCode], [ShipCity], [ShipState], [ShipCountry], [PhotoUrl], [LastLoginTime], [CreateDate], [IsManual], [IsVerified], [IsActive], [IsDelete], [IsSync], [Code], [Permissions], [CustomerCode]) VALUES (N'00000000-0000-0000-0000-000000000000', N'Guest', N'Guest', N'Guest', NULL, NULL, NULL, NULL, N'Oita', NULL, NULL, NULL, CAST(0x0000AC0E010ADE24 AS DateTime), NULL, 1, 1, 0, 1, NULL, NULL, 1003)
INSERT [dbo].[Users] ([Id], [Username], [Password], [FirstName], [LastName], [ShipAddress], [ShipZipCode], [ShipCity], [ShipState], [ShipCountry], [PhotoUrl], [LastLoginTime], [CreateDate], [IsManual], [IsVerified], [IsActive], [IsDelete], [IsSync], [Code], [Permissions], [CustomerCode]) VALUES (N'2000eb30-80ef-46e8-b7ff-6698f79dd057', N'manager_Deleted_637390750357181833', N'manager123', N'MAHIDUL', N'ISLAM', NULL, NULL, NULL, NULL, NULL, NULL, NULL, CAST(0x0000AC2101771208 AS DateTime), 1, 0, 1, 1, NULL, NULL, NULL, 1004)
INSERT [dbo].[Users] ([Id], [Username], [Password], [FirstName], [LastName], [ShipAddress], [ShipZipCode], [ShipCity], [ShipState], [ShipCountry], [PhotoUrl], [LastLoginTime], [CreateDate], [IsManual], [IsVerified], [IsActive], [IsDelete], [IsSync], [Code], [Permissions], [CustomerCode]) VALUES (N'4af3f626-add4-4cba-8bbd-e140a3bdd8be', N'manager', N'abc', N'Manager', N'Manager', NULL, NULL, NULL, NULL, NULL, NULL, CAST(0x0000ACFC008A2005 AS DateTime), CAST(0x0000ACDE010ECAEF AS DateTime), 1, 0, 1, 0, 1, N'sales', N'product-m;addProduct-sm;productList-sm;purchase-m;customer-m;manageStock-m;order-m;configuration-m;report-m;setting-sm;', 1006)
INSERT [dbo].[Users] ([Id], [Username], [Password], [FirstName], [LastName], [ShipAddress], [ShipZipCode], [ShipCity], [ShipState], [ShipCountry], [PhotoUrl], [LastLoginTime], [CreateDate], [IsManual], [IsVerified], [IsActive], [IsDelete], [IsSync], [Code], [Permissions], [CustomerCode]) VALUES (N'51c57015-1c02-4751-b68d-516882b9a901', N'02566454', N'a', N'Anderson', NULL, N'Houston, Texas, United State', N'12345', N'Texas', N'Houston', NULL, NULL, CAST(0x0000AEEC0178CBF1 AS DateTime), CAST(0x0000ACB500D5A53D AS DateTime), NULL, 1, 1, 0, 1, NULL, NULL, 1001)
INSERT [dbo].[Users] ([Id], [Username], [Password], [FirstName], [LastName], [ShipAddress], [ShipZipCode], [ShipCity], [ShipState], [ShipCountry], [PhotoUrl], [LastLoginTime], [CreateDate], [IsManual], [IsVerified], [IsActive], [IsDelete], [IsSync], [Code], [Permissions], [CustomerCode]) VALUES (N'66ceedef-763c-4f15-9a73-f1338c1aebee', N'mb_Deleted_637390750428661437', N'mb123', N'MB', N'GLOBAL NETWORK', NULL, NULL, NULL, NULL, NULL, NULL, CAST(0x0000AC5C00B022ED AS DateTime), CAST(0x0000AC280115BADD AS DateTime), 1, 0, 1, 1, NULL, NULL, NULL, 1005)
INSERT [dbo].[Users] ([Id], [Username], [Password], [FirstName], [LastName], [ShipAddress], [ShipZipCode], [ShipCity], [ShipState], [ShipCountry], [PhotoUrl], [LastLoginTime], [CreateDate], [IsManual], [IsVerified], [IsActive], [IsDelete], [IsSync], [Code], [Permissions], [CustomerCode]) VALUES (N'99f048d1-d84e-4ea0-ae47-5726e155677e', N'admin', N'pass123', N'Administrator', N'admin', N'', N'55687979', N'', N'Oita', N'', NULL, CAST(0x0000AEED00F88168 AS DateTime), CAST(0x0000A7F900A2AEFD AS DateTime), 1, 1, 1, 0, 1, NULL, N'product-m;addProduct-sm;productList-sm;purchase-m;customer-m;manageStock-m;order-m;configuration-m;report-m;setting-sm;', 1002)
INSERT [dbo].[Users] ([Id], [Username], [Password], [FirstName], [LastName], [ShipAddress], [ShipZipCode], [ShipCity], [ShipState], [ShipCountry], [PhotoUrl], [LastLoginTime], [CreateDate], [IsManual], [IsVerified], [IsActive], [IsDelete], [IsSync], [Code], [Permissions], [CustomerCode]) VALUES (N'fb502a0e-913f-4147-830e-67e0bda7413f', N'aa', N'aa', N'aa', N'aa', NULL, NULL, NULL, NULL, NULL, NULL, CAST(0x0000ACE000973BB6 AS DateTime), CAST(0x0000ACE000971D48 AS DateTime), 1, 0, 1, 0, 1, N'11', N'product-m;addProduct-sm;productList-sm;purchase-m;customer-m;manageStock-m;order-m;configuration-m;report-m;setting-sm;', 1007)
SET IDENTITY_INSERT [dbo].[Users] OFF
/****** Object:  Index [PK_ELMAH_Error]    Script Date: 8/11/2022 9:55:49 AM ******/
ALTER TABLE [dbo].[ELMAH_Error] ADD  CONSTRAINT [PK_ELMAH_Error] PRIMARY KEY NONCLUSTERED 
(
	[ErrorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [IX_ELMAH_Error_App_Time_Seq]    Script Date: 8/11/2022 9:55:49 AM ******/
CREATE NONCLUSTERED INDEX [IX_ELMAH_Error_App_Time_Seq] ON [dbo].[ELMAH_Error]
(
	[Application] ASC,
	[TimeUtc] DESC,
	[Sequence] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UC_username]    Script Date: 8/11/2022 9:55:49 AM ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [UC_username] UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON

GO
/****** Object:  Index [UQ__Users__536C85E4D0FA8D4C]    Script Date: 8/11/2022 9:55:49 AM ******/
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [UQ__Users__536C85E4D0FA8D4C] UNIQUE NONCLUSTERED 
(
	[Username] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ActionLogs] ADD  CONSTRAINT [DF_ActionLogs_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[ELMAH_Error] ADD  CONSTRAINT [DF_ELMAH_Error_ErrorId]  DEFAULT (newid()) FOR [ErrorId]
GO
ALTER TABLE [dbo].[OrderItems] ADD  CONSTRAINT [DF_OrderItems_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[OrderItems] ADD  CONSTRAINT [DF_OrderItems_ActionDate]  DEFAULT (getdate()) FOR [ActionDate]
GO
ALTER TABLE [dbo].[Orders] ADD  CONSTRAINT [DF_Orders_ActionDate]  DEFAULT (getdate()) FOR [ActionDate]
GO
ALTER TABLE [dbo].[ProductImages] ADD  CONSTRAINT [DF_ProductImages_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[ProductImages] ADD  CONSTRAINT [DF_ProductImages_ActionDate]  DEFAULT (getdate()) FOR [ActionDate]
GO
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [DF_Products_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [DF_Products_ActionDate]  DEFAULT (getdate()) FOR [ActionDate]
GO
ALTER TABLE [dbo].[ProductStocks] ADD  CONSTRAINT [DF_ProductStockLocations_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[Purchase] ADD  CONSTRAINT [DF_Purchase_Id]  DEFAULT (newid()) FOR [Id]
GO
ALTER TABLE [dbo].[Purchase] ADD  CONSTRAINT [DF_Purchase_ActionDate]  DEFAULT (getdate()) FOR [ActionDate]
GO
ALTER TABLE [dbo].[Users] ADD  CONSTRAINT [DF_Users_Created]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Category]  WITH CHECK ADD  CONSTRAINT [FK_Category_Category] FOREIGN KEY([ParentId])
REFERENCES [dbo].[Category] ([Id])
GO
ALTER TABLE [dbo].[Category] CHECK CONSTRAINT [FK_Category_Category]
GO
ALTER TABLE [dbo].[OrderItems]  WITH CHECK ADD  CONSTRAINT [FK_OrderItems_Orders] FOREIGN KEY([OrderId])
REFERENCES [dbo].[Orders] ([Id])
GO
ALTER TABLE [dbo].[OrderItems] CHECK CONSTRAINT [FK_OrderItems_Orders]
GO
ALTER TABLE [dbo].[OrderItems]  WITH CHECK ADD  CONSTRAINT [FK_OrderItems_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[OrderItems] CHECK CONSTRAINT [FK_OrderItems_Products]
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD FOREIGN KEY([BranchId])
REFERENCES [dbo].[Branch] ([Id])
GO
ALTER TABLE [dbo].[Orders]  WITH CHECK ADD  CONSTRAINT [FK_Orders_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Users]
GO
ALTER TABLE [dbo].[ProductImages]  WITH CHECK ADD  CONSTRAINT [FK_ProductImages_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[ProductImages] CHECK CONSTRAINT [FK_ProductImages_Products]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Branch] FOREIGN KEY([BranchId])
REFERENCES [dbo].[Branch] ([Id])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Branch]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Category] FOREIGN KEY([CategoryId])
REFERENCES [dbo].[Category] ([Id])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Category]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_ItemTypes] FOREIGN KEY([ItemTypeId])
REFERENCES [dbo].[ItemTypes] ([Id])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_ItemTypes]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Products] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Products]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Suppliers] FOREIGN KEY([SupplierId])
REFERENCES [dbo].[Suppliers] ([Id])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Suppliers]
GO
ALTER TABLE [dbo].[ProductStocks]  WITH CHECK ADD  CONSTRAINT [FK_ProductStocks_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[ProductStocks] CHECK CONSTRAINT [FK_ProductStocks_Products]
GO
ALTER TABLE [dbo].[ProductStocks]  WITH CHECK ADD  CONSTRAINT [FK_ProductStocks_StockLocations] FOREIGN KEY([StockLocationId])
REFERENCES [dbo].[StockLocations] ([Id])
GO
ALTER TABLE [dbo].[ProductStocks] CHECK CONSTRAINT [FK_ProductStocks_StockLocations]
GO
ALTER TABLE [dbo].[Purchase]  WITH CHECK ADD  CONSTRAINT [FK_Purchase_Products] FOREIGN KEY([ProductId])
REFERENCES [dbo].[Products] ([Id])
GO
ALTER TABLE [dbo].[Purchase] CHECK CONSTRAINT [FK_Purchase_Products]
GO
ALTER TABLE [dbo].[Purchase]  WITH CHECK ADD  CONSTRAINT [FK_Purchase_Suppliers] FOREIGN KEY([SupplierId])
REFERENCES [dbo].[Suppliers] ([Id])
GO
ALTER TABLE [dbo].[Purchase] CHECK CONSTRAINT [FK_Purchase_Suppliers]
GO
ALTER TABLE [dbo].[UserBranches]  WITH CHECK ADD  CONSTRAINT [FK_UserBranches_Branch] FOREIGN KEY([BranchId])
REFERENCES [dbo].[Branch] ([Id])
GO
ALTER TABLE [dbo].[UserBranches] CHECK CONSTRAINT [FK_UserBranches_Branch]
GO
ALTER TABLE [dbo].[UserBranches]  WITH CHECK ADD  CONSTRAINT [FK_UserBranches_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[UserBranches] CHECK CONSTRAINT [FK_UserBranches_Users]
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_UserRoles_Roles] FOREIGN KEY([RoleId])
REFERENCES [dbo].[Roles] ([Id])
GO
ALTER TABLE [dbo].[UserRoles] CHECK CONSTRAINT [FK_UserRoles_Roles]
GO
ALTER TABLE [dbo].[UserRoles]  WITH CHECK ADD  CONSTRAINT [FK_UserRoles_Users] FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
GO
ALTER TABLE [dbo].[UserRoles] CHECK CONSTRAINT [FK_UserRoles_Users]
GO
USE [master]
GO
ALTER DATABASE [ECommerce] SET  READ_WRITE 
GO
