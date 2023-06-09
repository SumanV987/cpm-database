/****** Object:  Database [cpm-db]    Script Date: 4/5/2023 9:51:03 AM ******/
CREATE DATABASE [cpm-db]  (EDITION = 'GeneralPurpose', SERVICE_OBJECTIVE = 'GP_S_Gen5_1', MAXSIZE = 32 GB) WITH CATALOG_COLLATION = SQL_Latin1_General_CP1_CI_AS;
GO
ALTER DATABASE [cpm-db] SET COMPATIBILITY_LEVEL = 150
GO
ALTER DATABASE [cpm-db] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [cpm-db] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [cpm-db] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [cpm-db] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [cpm-db] SET ARITHABORT OFF 
GO
ALTER DATABASE [cpm-db] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [cpm-db] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [cpm-db] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [cpm-db] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [cpm-db] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [cpm-db] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [cpm-db] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [cpm-db] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [cpm-db] SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE [cpm-db] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [cpm-db] SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE [cpm-db] SET  MULTI_USER 
GO
ALTER DATABASE [cpm-db] SET ENCRYPTION ON
GO
ALTER DATABASE [cpm-db] SET QUERY_STORE = ON
GO
ALTER DATABASE [cpm-db] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 100, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
/*** The scripts of database scoped configurations in Azure should be executed inside the target database connection. ***/
GO
-- ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 8;
GO
/****** Object:  DatabaseScopedCredential [https://azasstaexnseq01948ewdl.blob.core.windows.net/sqldbauditlogs]    Script Date: 4/5/2023 9:51:03 AM ******/
CREATE DATABASE SCOPED CREDENTIAL [https://azasstaexnseq01948ewdl.blob.core.windows.net/sqldbauditlogs] WITH IDENTITY = N'SHARED ACCESS SIGNATURE'
GO
/****** Object:  User [SQLRWCPM]    Script Date: 4/5/2023 9:51:03 AM ******/
CREATE USER [SQLRWCPM] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [db_etl_user]    Script Date: 4/5/2023 9:51:04 AM ******/
CREATE ROLE [db_etl_user]
GO
sys.sp_addrolemember @rolename = N'db_etl_user', @membername = N'SQLRWCPM'
GO
sys.sp_addrolemember @rolename = N'db_ddladmin', @membername = N'SQLRWCPM'
GO
sys.sp_addrolemember @rolename = N'db_datareader', @membername = N'SQLRWCPM'
GO
sys.sp_addrolemember @rolename = N'db_datawriter', @membername = N'SQLRWCPM'
GO
EXEC sys.sp_addrolemember @rolename = N'db_ddladmin', @membername = N'db_etl_user'
GO
EXEC sys.sp_addrolemember @rolename = N'db_datareader', @membername = N'db_etl_user'
GO
EXEC sys.sp_addrolemember @rolename = N'db_datawriter', @membername = N'db_etl_user'
GO
/****** Object:  Schema [CPM]    Script Date: 4/5/2023 9:51:04 AM ******/
CREATE SCHEMA [CPM]
GO
/****** Object:  Schema [PLANNING_ONE]    Script Date: 4/5/2023 9:51:04 AM ******/
CREATE SCHEMA [PLANNING_ONE]
GO
/****** Object:  Schema [PlanningOne]    Script Date: 4/5/2023 9:51:04 AM ******/
CREATE SCHEMA [PlanningOne]
GO
/****** Object:  Schema [ReportOne]    Script Date: 4/5/2023 9:51:04 AM ******/
CREATE SCHEMA [ReportOne]
GO
/****** Object:  Schema [Tanso]    Script Date: 4/5/2023 9:51:04 AM ******/
CREATE SCHEMA [Tanso]
GO
/****** Object:  Synonym [dbo].[Get_Conversion_Fact1]    Script Date: 4/5/2023 9:51:05 AM ******/
CREATE SYNONYM [dbo].[Get_Conversion_Fact1] FOR [dbo].[Get_Conversion_Fact]
GO
/****** Object:  UserDefinedFunction [dbo].[Get_Conversion_Fact]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[Get_Conversion_Fact] (@vol_uom VARCHAR(250),@intensity_uom VARCHAR(250),@TRADE_COMMODITY_NAME VARCHAR(250))
RETURNS DECIMAL(30,15)
AS BEGIN
    DECLARE @conversion_value DECIMAL(30,15)
	SET @conversion_value = 
	( 
	SELECT CONVERSION
	FROM [dbo].[UNIT_CONVERSION]
	WHERE upper(BASE_UOM) = upper(@vol_uom)
	AND upper(TARGET_UOM) = upper(@intensity_uom)
	AND upper(COMMODITY) = upper(@TRADE_COMMODITY_NAME)
	);

    RETURN @conversion_value
END
GO
/****** Object:  UserDefinedFunction [PlanningOne].[Get_Conversion_Fact]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [PlanningOne].[Get_Conversion_Fact] (@vol_uom VARCHAR(250),@intensity_uom VARCHAR(250),@TRADE_COMMODITY_NAME VARCHAR(250))
RETURNS DECIMAL(30,15)
AS BEGIN
    DECLARE @conversion_value DECIMAL(30,15)
	SET @conversion_value = 
	( 
	SELECT CONVERSION
	FROM [PlanningOne].[DIM_UNIT_CONVERSION]
	WHERE upper(BASE_UOM) = upper(@vol_uom)
	AND upper(TARGET_UOM) = upper(@intensity_uom)
	AND upper(COMMODITY) = upper(@TRADE_COMMODITY_NAME)
	);

    RETURN @conversion_value
END
GO
/****** Object:  View [dbo].[gross_profit_IPU]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  VIEW [dbo].[gross_profit_IPU]
 AS 
(
SELECT 
DB.[BUSINESS_UNIT_ID],
DB.[YEAR],
DB.PURCHASES_GA,
DB.REVENUES_GA,
DB.[GROSS_PROFIT],
BUN.UpsAsHi_Performance_UnitName,
'Admin' as CreatedBy,
getdate() as CreatedDate,
'Admin' as ModifiedBy,
getdate() as ModifiedData
 from deal_book as DB 
left join [dbo].[BUSINESS_UNIT_NEW] BUN on BUN.[BUSINESS_UNIT_ID]=DB.BUSINESS_UNIT_ID
LEFT JOIN 
(select [UpsAsHi_Performance_UnitName],
year, sum([Inland_Sales_Other])-sum([Purchases_Other]) as gross_profit 
from [dbo].[Data_request_AE_Data_report] 
group by UpsAsHi_Performance_UnitName,year)  as GP  
ON GP.[UpsAsHi_Performance_UnitName]=
BUN.[UpsAsHi_Performance_UnitName]
AND GP.YEAR=DB.YEAR
)
GO
/****** Object:  View [dbo].[VW_CarbonEmissionPerIPU]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VW_CarbonEmissionPerIPU]    
AS 

WITH CarbonEmission  
AS  
(  
SELECT --DISTINCT   
      (SeLECT LINE_OF_BUSINESS FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  EVP  
     ,(SeLECT UpsAsHi_Performance_UnitName FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  IPU  
     ,(SeLECT BUSINESS_DOMAIN FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  VP     
     ,(SeLECT Reporting_Entity_Name FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  Reporting_Entity_Name  
 --   (SeLECT Activity_Entity_Name FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  BUSINESS_UNIT  
     ,(SeLECT REGION_NAME FROM [PlanningOne].[DIM_REGION]  WHERE REGION_ID  = [DQ].REGION_ID) as REGION  
	 ,[DQ].REGION_ID
     ,(SeLECT COUNTRY_NAME FROM [PlanningOne].[DIM_COUNTRY]  WHERE COUNTRY_ID  = [DQ].COUNTRY_ID) as COUNTRY 
     ,[TC].TRADE_COMMODITY_NAME   
     ,[DQ].[TRADE_COMMODITY_ID]    
     ,DATEPART(YEAR,[DQ].TRADE_DATE) AS [TRADE_YEAR]  
     ,[DQ].TRADE_DATE  
     ,(SeLECT PARAMETER_NAME FROM [PlanningOne].[DIM_PARAMETER]  WHERE PARAMETER_ID  = [DQ].PARAMETER_ID) as KPI  
     ,[DQ].PARAMETER_ID  
     ,[DQ].CARBON_EMISSION  
     ,(SeLECT UNIT_CODE FROM [PlanningOne].[DIM_UNIT_OF_MEASURE]  WHERE UNIT_ID = [DQ].UNIT_CODE) as UOM   
     ,[DQ].QUANTITY 

FROM [PlanningOne].[FACT_DEAL_QUANTITY] AS [DQ] WITH (NOLOCK)  
INNER JOIN [PlanningOne].[DIM_TRADED_COMMODITY] AS [TC] WITH (NOLOCK)   
   ON [DQ].[TRADE_COMMODITY_ID] = [TC].[TRADE_COMMODITY_ID]    
)   
SELECT [CE].IPU 
	,[CE].REGION
	,[CE].REGION_ID
    ,[CE].TRADE_DATE 
    ,[TRADE_YEAR]  
    ,[CE].TRADE_COMMODITY_NAME 
    ,[CE].TRADE_COMMODITY_ID 
    ,[CE].KPI 
    ,[CE].PARAMETER_ID 
    ,sum(CARBON_EMISSION)  AS CARBON_EMISSION
  --,count(CARBON_EMISSION)  AS COUNT_CARBON_EMISSION
FROM CarbonEmission AS [CE]  
--WHERE [CE].IPU  = 'Hydrogen'
-- and [CE].TRADE_COMMODITY_NAME ='Hydrogen'
-- and [CE].KPI ='Green Hydrogen Production'
-- and [TRADE_YEAR]  ='2023'
GROUP BY [CE].IPU 
	,[CE].REGION
	,[CE].REGION_ID
   ,[CE].TRADE_DATE 
   ,[TRADE_YEAR]  
   ,[CE].TRADE_COMMODITY_NAME 
   ,[CE].TRADE_COMMODITY_ID 
   ,[CE].KPI 
   ,[CE].PARAMETER_ID ;

--ORDER BY [CE].IPU 
--	,[CE].REGION
--	,[CE].REGION_ID
--   ,[CE].TRADE_DATE  
--   ,[CE].TRADE_COMMODITY_NAME 
--   ,[CE].TRADE_COMMODITY_ID 
--   ,[CE].KPI 
--   ,[CE].PARAMETER_ID 


GO
/****** Object:  View [dbo].[vw_FACT_DEAL_QUANTITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_FACT_DEAL_QUANTITY]   
AS 


SELECT --DISTINCT   
      (SeLECT LINE_OF_BUSINESS FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  EVP  
     ,(SeLECT UpsAsHi_Performance_UnitName FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  IPU  
     ,(SeLECT BUSINESS_DOMAIN FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  VP     
     ,(SeLECT Reporting_Entity_Name FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  Reporting_Entity_Name  
     ,(SeLECT Activity_Entity_Name FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  BUSINESS_UNIT 
	 ,[DQ].BUSINESS_UNIT_ID
     ,(SeLECT REGION_NAME FROM [PlanningOne].[DIM_REGION]  WHERE REGION_ID  = [DQ].REGION_ID) as REGION  
	 ,[DQ].REGION_ID
     ,(SeLECT COUNTRY_NAME FROM [PlanningOne].[DIM_COUNTRY]  WHERE COUNTRY_ID  = [DQ].COUNTRY_ID) as COUNTRY 
	 ,[DQ].COUNTRY_ID
     ,[TC].TRADE_COMMODITY_NAME   
     ,[DQ].[TRADE_COMMODITY_ID]    
    -- ,DATEPART(YEAR,[DQ].TRADE_DATE) AS [TRADE_YEAR]  
     ,[DQ].TRADE_DATE  
     ,(SeLECT PARAMETER_NAME FROM [PlanningOne].[DIM_PARAMETER]  WHERE PARAMETER_ID  = [DQ].PARAMETER_ID) as KPI  
     ,[DQ].PARAMETER_ID  
     ,[DQ].CARBON_EMISSION  
     ,(SeLECT UNIT_CODE FROM [PlanningOne].[DIM_UNIT_OF_MEASURE]  WHERE UNIT_ID = [DQ].UNIT_CODE) as UOM   
     ,[DQ].QUANTITY 

--FROM [PlanningOne].[FACT_DEAL_QUANTITY] AS [DQ] WITH (NOLOCK)  
FROM [dbo].[DEAL_QUANTITY] AS [DQ] WITH (NOLOCK) 
INNER JOIN [PlanningOne].[DIM_TRADED_COMMODITY] AS [TC] WITH (NOLOCK)   
   ON [DQ].[TRADE_COMMODITY_ID] = [TC].[TRADE_COMMODITY_ID] ; 
   
--ORDER BY IPU 
--	,REGION
--	,REGION_ID
--    ,TRADE_DATE 
--   ,[TRADE_YEAR]  
--   ,TRADE_COMMODITY_NAME 
--   ,TRADE_COMMODITY_ID 
--   ,KPI 
--   ,PARAMETER_ID ;




GO
/****** Object:  View [dbo].[vw_GrossProfit_IPU]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_GrossProfit_IPU]
AS
WITH GrossProfit  
AS  
( 

SELECT distinct
      (SELECT LINE_OF_BUSINESS FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DB].BUSINESS_UNIT_ID) as  EVP  
     ,(SELECT UpsAsHi_Performance_UnitName FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DB].BUSINESS_UNIT_ID) as  IPU  
     ,(SELECT BUSINESS_DOMAIN FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DB].BUSINESS_UNIT_ID) as  VP     
     ,(SELECT Reporting_Entity_Name FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DB].BUSINESS_UNIT_ID) as  Reporting_Entity_Name  
 --   (SELECT Activity_Entity_Name FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  BUSINESS_UNIT  
     ,(SELECT REGION_NAME 
	     FROM [PlanningOne].[DIM_REGION] AS R
	     INNER JOIN [PlanningOne].[DIM_BUSINESS_UNIT] AS BU
	          ON R.REGION_ID  = BU.[Carbon_Region]
		WHERE BUSINESS_UNIT_ID  = [DB].BUSINESS_UNIT_ID) as REGION  
     ,(SELECT BU.[Carbon_Region] 
	    FROM [PlanningOne].[DIM_BUSINESS_UNIT] AS BU
		WHERE BUSINESS_UNIT_ID  = [DB].BUSINESS_UNIT_ID) as REGION_ID  
      ,  DB.[YEAR]
      ,  DB.[GROSS_PROFIT] 
FROM [PlanningOne].[FACT_DEAL_BOOK] AS DB  

--ORDER BY EVP, IPU,VP, Reporting_Entity_Name, REGION 

)
SELECT [GP].IPU  
   --   ,[GP].REGION
	  --,REGION_ID 
      ,[GP].[YEAR]
      ,SUM([GP].[GROSS_PROFIT]) AS   [GROSS_PROFIT]
FROM GrossProfit AS [GP]  
--WHERE [GP].IPU  = 'Hydrogen'
-- and [GP].TRADE_COMMODITY_NAME ='Hydrogen'
-- and [GP].KPI ='Green Hydrogen Production'
 -- and [YEAR]  ='2023'
GROUP BY [GP].IPU  
  --   ,[GP].REGION
	 --,REGION_ID 
     ,[GP].[YEAR]
     
GO
/****** Object:  View [dbo].[vw_MARGIN_CARBON_RATIO]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_MARGIN_CARBON_RATIO]
AS
WITH CarbonEmission
AS
(
SELECT 	IPU
       ,Trade_year 
	   ,SUM(CARBON_EMISSION) AS CARBON_EMISSION
FROM [dbo].[VW_CarbonEmissionPerIPU] AS [GP]
GROUP BY IPU
       ,Trade_year
)
SELECT [CE].IPU
	  ,[CE].[TRADE_YEAR]

	  ,CASE
    WHEN    [CE].CARBON_EMISSION = 0 THEN 0 
    ELSE   [GP].GROSS_PROFIT/[CE].CARBON_EMISSION 
    END AS Margin_Carbon_Ratio
FROM CarbonEmission AS [CE]
INNER JOIN [dbo].[vw_GrossProfit_IPU] AS [GP]
ON [CE].IPU = [GP].IPU
AND [CE].[TRADE_YEAR] = [GP].[YEAR];
GO
/****** Object:  View [dbo].[vw_OverAllPortfolio]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_OverAllPortfolio]    
AS    
(    
    
    
SELECT --DISTINCT     
      (SeLECT LINE_OF_BUSINESS FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  EVP    
     ,(SeLECT UpsAsHi_Performance_UnitName FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  IPU    
     ,(SeLECT BUSINESS_DOMAIN FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  VP       
     ,(SeLECT Reporting_Entity_Name FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  Reporting_Entity_Name    
 --   (SeLECT Activity_Entity_Name FROM [PlanningOne].[DIM_BUSINESS_UNIT]  WHERE BUSINESS_UNIT_ID  = [DQ].BUSINESS_UNIT_ID) as  BUSINESS_UNIT    
     ,(SeLECT REGION_NAME FROM [PlanningOne].[DIM_REGION]  WHERE REGION_ID  = [DQ].REGION_ID) as REGION    
     ,(SeLECT COUNTRY_NAME FROM [PlanningOne].[DIM_COUNTRY]  WHERE COUNTRY_ID  = [DQ].COUNTRY_ID) as COUNTRY    
     ,[TC].TRADE_COMMODITY_NAME     
     ,[DQ].[TRADE_COMMODITY_ID]      
     ,DATEPART(YEAR,[DQ].TRADE_DATE) AS [TRADE_YEAR]    
     ,[DQ].TRADE_DATE    
     ,(SeLECT PARAMETER_NAME FROM [PlanningOne].[DIM_PARAMETER]  WHERE PARAMETER_ID  = [DQ].PARAMETER_ID) as KPI    
     ,[DQ].PARAMETER_ID    
     ,[DQ].CARBON_EMISSION    
     ,(SeLECT UNIT_CODE FROM [PlanningOne].[DIM_UNIT_OF_MEASURE]  WHERE UNIT_ID = [DQ].UNIT_CODE) as UOM     
     ,[DQ].QUANTITY    
     ,[SOURCE]    
FROM [PlanningOne].[FACT_DEAL_QUANTITY] AS [DQ] WITH (NOLOCK)    
INNER JOIN [PlanningOne].[DIM_TRADED_COMMODITY] AS [TC] WITH (NOLOCK)     
   ON [DQ].[TRADE_COMMODITY_ID] = [TC].[TRADE_COMMODITY_ID]     
--WHERE [DQ].QUANTITY <> 0.000000    
  --[DQ].CARBON_EMISSION <> 0.000000    
--ORDER BY EVP, IPU,VP, Reporting_Entity_Name, REGION, COUNTRY, TRADE_COMMODITY_NAME    
)
GO
/****** Object:  Table [CPM].[ADT_SOURCE_MAPPING_TABLE]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[ADT_SOURCE_MAPPING_TABLE](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sheetname] [varchar](500) NULL,
	[FileName] [varchar](500) NULL,
	[TargetSchema] [varchar](500) NULL,
	[TargetTable] [varchar](500) NULL,
	[Activeflag] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_BUSINESS]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_BUSINESS](
	[BUSINESS_ID] [int] NOT NULL,
	[BUSINESS_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_BUSINESS] PRIMARY KEY CLUSTERED 
(
	[BUSINESS_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_BUSINESS_UNIT]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_BUSINESS_UNIT](
	[BUSINESS_UNIT_ID] [int] NOT NULL,
	[Activity_Entity_Name] [varchar](100) NULL,
	[Reporting_Entity_Name] [varchar](100) NULL,
	[BUSINESS_DOMAIN] [varchar](100) NULL,
	[LINE_OF_BUSINESS] [varchar](100) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[UpsAsHi_Performance_UnitName] [varchar](100) NULL,
	[Carbon_Region] [int] NOT NULL,
 CONSTRAINT [PK_DIM_BUSINESS_UNIT] PRIMARY KEY CLUSTERED 
(
	[BUSINESS_UNIT_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_CARBON_INTENSITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_CARBON_INTENSITY](
	[CARBON_INTENSITY_ID] [int] NULL,
	[PARAMETER_ID] [int] NULL,
	[COUNTRY_ID] [int] NULL,
	[REGION_ID] [int] NULL,
	[TECHNOLOGY_SOURCE_ID] [int] NULL,
	[TRADE_COMMODITY_ID] [int] NULL,
	[GRID_ID] [int] NULL,
	[Year] [int] NULL,
	[CARBON_INTENSITY] [decimal](12, 6) NULL,
	[UNIT_CODE] [varchar](256) NULL,
	[Source] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_COUNTRY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_COUNTRY](
	[COUNTRY_ID] [int] NOT NULL,
	[REGION_ID] [int] NOT NULL,
	[COUNTRY_CODE] [varchar](256) NOT NULL,
	[COUNTRY_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_COUNTRY] PRIMARY KEY CLUSTERED 
(
	[COUNTRY_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_GRID]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_GRID](
	[GRID_ID] [int] NOT NULL,
	[REGION_NAME] [varchar](256) NULL,
	[COUNTRY_CODE] [varchar](2) NULL,
	[COUNTRY_NAME] [varchar](256) NULL,
	[Grid] [varchar](256) NULL,
	[Grid_Preferred_Name] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_GRID] PRIMARY KEY CLUSTERED 
(
	[GRID_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_PARAMETER]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_PARAMETER](
	[PARAMETER_ID] [int] NOT NULL,
	[PARAMETER_CODE] [varchar](100) NOT NULL,
	[PARAMETER_NAME] [varchar](100) NULL,
	[TRADE_COMMODITY_ID] [int] NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_PARAMETER] PRIMARY KEY CLUSTERED 
(
	[PARAMETER_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_REGION]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_REGION](
	[REGION_ID] [int] NOT NULL,
	[REGION_CODE] [varchar](60) NULL,
	[REGION_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_REGION] PRIMARY KEY CLUSTERED 
(
	[REGION_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_TECHNOLOGY_CLASSIFICATION]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_TECHNOLOGY_CLASSIFICATION](
	[TECHNOLOGY_CLASS_ID] [int] NOT NULL,
	[TECHNOLOGY_CLASS_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_TECHNOLOGY_CLASSIFICATION] PRIMARY KEY CLUSTERED 
(
	[TECHNOLOGY_CLASS_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_TECHNOLOGY_SOURCE]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_TECHNOLOGY_SOURCE](
	[TECHNOLOGY_SOURCE_ID] [int] NULL,
	[TECHNOLOGY_CLASS_ID] [int] NULL,
	[TECHNOLOGY_SOURCE_NAME] [varchar](200) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_TRADED_COMMODITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_TRADED_COMMODITY](
	[TRADE_COMMODITY_ID] [int] NOT NULL,
	[TRADE_COMMODITY_CODE] [varchar](60) NULL,
	[TRADE_COMMODITY_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_TRADED_COMMODITY] PRIMARY KEY CLUSTERED 
(
	[TRADE_COMMODITY_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_UNIT_CONVERSION]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_UNIT_CONVERSION](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[COMMODITY] [varchar](50) NOT NULL,
	[BASE_UOM] [varchar](50) NOT NULL,
	[TARGET_UOM] [varchar](50) NOT NULL,
	[CONVERSION] [decimal](30, 15) NULL,
	[Createdby] [varchar](256) NOT NULL,
	[createddate] [datetime] NOT NULL,
	[Modifiedby] [varchar](256) NOT NULL,
	[Modifieddate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[DIM_UNIT_OF_MEASURE]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[DIM_UNIT_OF_MEASURE](
	[UNIT_ID] [int] NOT NULL,
	[UNIT_CODE] [varchar](60) NULL,
	[UNIT_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_UNIT_OF_MEASURE] PRIMARY KEY CLUSTERED 
(
	[UNIT_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[FACT_DEAL_BOOK]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[FACT_DEAL_BOOK](
	[DEAL_BOOK_ID] [int] IDENTITY(1,1) NOT NULL,
	[BUSINESS_UNIT_ID] [int] NOT NULL,
	[YEAR] [int] NULL,
	[PURCHASES_GA] [decimal](18, 0) NULL,
	[REVENUES_GA] [decimal](18, 0) NULL,
	[GROSS_PROFIT] [decimal](18, 0) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_FACT_DEAL_BOOK] PRIMARY KEY CLUSTERED 
(
	[DEAL_BOOK_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [CPM].[FACT_DEAL_QUANTITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [CPM].[FACT_DEAL_QUANTITY](
	[DEAL_QUANTITY_ID] [int] IDENTITY(1,1) NOT NULL,
	[BUSINESS_UNIT_ID] [int] NOT NULL,
	[REGION_ID] [int] NOT NULL,
	[COUNTRY_ID] [int] NOT NULL,
	[TRADE_COMMODITY_ID] [int] NOT NULL,
	[TRADE_DATE] [date] NOT NULL,
	[UNIT_CODE] [int] NOT NULL,
	[PARAMETER_ID] [int] NOT NULL,
	[QUANTITY] [decimal](18, 6) NULL,
	[CARBON_EMISSION] [decimal](18, 6) NULL,
	[SOURCE] [varchar](100) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_FACT_DEAL_QUANTITY] PRIMARY KEY CLUSTERED 
(
	[DEAL_QUANTITY_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BUSINESS]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BUSINESS](
	[BUSINESS_ID] [int] NOT NULL,
	[BUSINESS_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_BUSINESS] PRIMARY KEY CLUSTERED 
(
	[BUSINESS_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BUSINESS_UNIT]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BUSINESS_UNIT](
	[BUSINESS_UNIT_ID] [int] NOT NULL,
	[Activity_Entity_Name] [varchar](100) NULL,
	[Reporting_Entity_Name] [varchar](100) NULL,
	[BUSINESS_DOMAIN] [varchar](100) NULL,
	[LINE_OF_BUSINESS] [varchar](100) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[UpsAsHi_Performance_UnitName] [varchar](100) NULL,
 CONSTRAINT [PK_BUSINESS_UNIT] PRIMARY KEY CLUSTERED 
(
	[BUSINESS_UNIT_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BUSINESS_UNIT_NEW]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BUSINESS_UNIT_NEW](
	[BUSINESS_UNIT_ID] [int] NOT NULL,
	[Activity_Entity_Name] [varchar](100) NULL,
	[Reporting_Entity_Name] [varchar](100) NULL,
	[BUSINESS_DOMAIN] [varchar](100) NULL,
	[LINE_OF_BUSINESS] [varchar](100) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[UpsAsHi_Performance_UnitName] [varchar](100) NULL,
	[Carbon_Region] [int] NOT NULL,
 CONSTRAINT [PK_BUSINESS_UNIT_id] PRIMARY KEY CLUSTERED 
(
	[BUSINESS_UNIT_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BUSINESS_UNIT_RAW]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BUSINESS_UNIT_RAW](
	[BUSINESS_UNIT_ID] [int] NOT NULL,
	[Activity_Entity_Name] [varchar](100) NULL,
	[Reporting_Entity_Name] [varchar](100) NULL,
	[BUSINESS_DOMAIN] [varchar](100) NULL,
	[LINE_OF_BUSINESS] [varchar](100) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[UpsAsHi_Performance_UnitName] [varchar](100) NULL,
	[Carbon_Region] [varchar](256) NOT NULL,
 CONSTRAINT [PK_BUSINESS_UNIT_ids] PRIMARY KEY CLUSTERED 
(
	[BUSINESS_UNIT_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CARBON_INTENSITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CARBON_INTENSITY](
	[CARBON_INTENSITY_ID] [int] NULL,
	[PARAMETER] [varchar](256) NULL,
	[REGION_ID] [int] NULL,
	[TRADE_COMMODITY_ID] [int] NULL,
	[Year] [int] NULL,
	[CARBON_INTENSITY] [decimal](12, 6) NULL,
	[UNIT_CODE] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[COUNTRY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[COUNTRY](
	[COUNTRY_ID] [int] NOT NULL,
	[REGION_ID] [int] NOT NULL,
	[COUNTRY_CODE] [varchar](256) NOT NULL,
	[COUNTRY_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_COUNTRY] PRIMARY KEY CLUSTERED 
(
	[COUNTRY_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_COUNTRY_AK_COUNTRY] UNIQUE NONCLUSTERED 
(
	[COUNTRY_CODE] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Data_request_AE_Data_report]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Data_request_AE_Data_report](
	[Version] [varchar](256) NULL,
	[Scenario] [varchar](256) NULL,
	[Year] [int] NULL,
	[Activity_Entity_Name] [varchar](256) NULL,
	[Reporting_Entity_Name] [varchar](256) NULL,
	[UpsAsHi_Performance_UnitName] [varchar](256) NULL,
	[Line_Of_Business] [varchar](256) NULL,
	[Business_Domain] [varchar](256) NULL,
	[Inland_Sales_Other] [decimal](18, 6) NULL,
	[Purchases_Other] [decimal](18, 6) NULL,
	[Inland_Sales_Volumes_NaturalGas] [decimal](18, 6) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Data_request_AE_Data_report_trans]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Data_request_AE_Data_report_trans](
	[Version] [varchar](256) NULL,
	[Scenario] [varchar](256) NULL,
	[Year] [int] NULL,
	[Activity_Entity_Name] [varchar](256) NULL,
	[Reporting_Entity_Name] [varchar](256) NULL,
	[UpsAsHi_Performance_UnitName] [varchar](256) NULL,
	[Line_Of_Business] [varchar](256) NULL,
	[Business_Domain] [varchar](256) NULL,
	[KPI] [varchar](256) NULL,
	[Quantity] [decimal](18, 6) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Data_request_AE_Power_report]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Data_request_AE_Power_report](
	[Version] [varchar](256) NULL,
	[Scenario] [varchar](256) NULL,
	[Year] [int] NULL,
	[Activity_Entity_Name] [varchar](256) NULL,
	[Reporting_Entity_Name] [varchar](256) NULL,
	[UpsAsHi_Performance_UnitName] [varchar](256) NULL,
	[Line_Of_Business] [varchar](256) NULL,
	[Business_Domain] [varchar](256) NULL,
	[_3P_Renewable_Power_Supply_PPA] [decimal](18, 6) NULL,
	[_3P_Gas_Fired_Power_Supply_PPA] [decimal](18, 6) NULL,
	[_3P_Power_Supply_Market_Pool] [decimal](18, 6) NULL,
	[Renewable_Attributes_REC] [decimal](18, 6) NULL,
	[Equity_Renewable_Power_Generation] [decimal](18, 6) NULL,
	[Equity_Gas_Fired_Power_Generation] [decimal](18, 6) NULL,
	[Blue_Hydrogen_Production] [decimal](18, 6) NULL,
	[Green_Hydrogen_Production] [decimal](18, 6) NULL,
	[Grey_Hydrogen_Production] [decimal](18, 6) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Data_request_AE_Power_report_trans]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Data_request_AE_Power_report_trans](
	[Version] [varchar](256) NULL,
	[Scenario] [varchar](256) NULL,
	[Year] [int] NULL,
	[Activity_Entity_Name] [varchar](256) NULL,
	[Reporting_Entity_Name] [varchar](256) NULL,
	[UpsAsHi_Performance_UnitName] [varchar](256) NULL,
	[Line_Of_Business] [varchar](256) NULL,
	[Business_Domain] [varchar](256) NULL,
	[KPI] [varchar](256) NULL,
	[Quantity] [decimal](18, 6) NULL,
	[UOM] [varchar](256) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DEAL_BOOK]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DEAL_BOOK](
	[DEAL_BOOK_ID] [int] IDENTITY(1,1) NOT NULL,
	[BUSINESS_UNIT_ID] [int] NOT NULL,
	[YEAR] [int] NULL,
	[PURCHASES_GA] [decimal](18, 0) NULL,
	[REVENUES_GA] [decimal](18, 0) NULL,
	[GROSS_PROFIT] [decimal](18, 0) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DEAL_BOOK] PRIMARY KEY NONCLUSTERED 
(
	[DEAL_BOOK_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DEAL_QUANTITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DEAL_QUANTITY](
	[DEAL_QUANTITY_ID] [int] IDENTITY(1,1) NOT NULL,
	[BUSINESS_UNIT_ID] [int] NOT NULL,
	[REGION_ID] [int] NOT NULL,
	[COUNTRY_ID] [int] NOT NULL,
	[TRADE_COMMODITY_ID] [int] NOT NULL,
	[TRADE_DATE] [date] NOT NULL,
	[UNIT_CODE] [int] NOT NULL,
	[PARAMETER_ID] [int] NOT NULL,
	[QUANTITY] [decimal](18, 6) NULL,
	[CARBON_EMISSION] [decimal](18, 6) NULL,
	[SOURCE] [varchar](100) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DEAL_QUANTITY] PRIMARY KEY CLUSTERED 
(
	[DEAL_QUANTITY_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GRID]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GRID](
	[GRID_ID] [int] NOT NULL,
	[REGION_NAME] [varchar](256) NULL,
	[COUNTRY_CODE] [varchar](2) NULL,
	[COUNTRY_NAME] [varchar](256) NULL,
	[Grid] [varchar](256) NULL,
	[Grid_Preferred_Name] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_GRID] PRIMARY KEY CLUSTERED 
(
	[GRID_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PARAMETER]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PARAMETER](
	[PARAMETER_ID] [int] NOT NULL,
	[PARAMETER_CODE] [varchar](100) NOT NULL,
	[PARAMETER_NAME] [varchar](100) NULL,
	[TRADE_COMMODITY_ID] [int] NULL,
	[Source] [varchar](256) NOT NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_PARAMETER] PRIMARY KEY CLUSTERED 
(
	[PARAMETER_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PLANNING_CARBON_INTENSITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PLANNING_CARBON_INTENSITY](
	[PLANNING_CARBON_INTENSITY_ID] [int] IDENTITY(1,1) NOT NULL,
	[Parameter_ID] [int] NULL,
	[REGION_ID] [int] NULL,
	[YEAR] [int] NULL,
	[Carbon_Intensity] [decimal](12, 6) NULL,
	[Unit_Code] [varchar](100) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Raw_P1_Carbon_intensity_data]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Raw_P1_Carbon_intensity_data](
	[Model_KPI] [varchar](256) NULL,
	[Carbon_Region] [varchar](256) NULL,
	[UoM] [varchar](256) NULL,
	[Year] [int] NULL,
	[Carbon_Intensity_Value] [decimal](18, 6) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[REGION]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[REGION](
	[REGION_ID] [int] NOT NULL,
	[REGION_CODE] [varchar](60) NULL,
	[REGION_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_REGION] PRIMARY KEY CLUSTERED 
(
	[REGION_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_REGION_AK_REGION] UNIQUE NONCLUSTERED 
(
	[REGION_CODE] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Report1_Raw]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Report1_Raw](
	[Column1] [nvarchar](max) NULL,
	[Column2] [nvarchar](max) NULL,
	[Column3] [nvarchar](max) NULL,
	[Column4] [nvarchar](max) NULL,
	[Column5] [nvarchar](max) NULL,
	[Column6] [nvarchar](max) NULL,
	[Column7] [nvarchar](max) NULL,
	[Column8] [nvarchar](max) NULL,
	[Column9] [nvarchar](max) NULL,
	[Column10] [nvarchar](max) NULL,
	[Column11] [nvarchar](max) NULL,
	[Column12] [nvarchar](max) NULL,
	[Column13] [nvarchar](max) NULL,
	[Column14] [nvarchar](max) NULL,
	[Column15] [nvarchar](max) NULL,
	[Column16] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Reporting_Hirarchy]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reporting_Hirarchy](
	[BU_ID] [nvarchar](max) NULL,
	[ActivityEntityName] [nvarchar](max) NULL,
	[ReportingEntityName] [nvarchar](max) NULL,
	[BusinessDomain] [nvarchar](max) NULL,
	[UpsAsHiPerformanceUnitName] [nvarchar](max) NULL,
	[LineOfBusiness] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SheetnamesDetails]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SheetnamesDetails](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sheetname] [varchar](500) NULL,
	[FileName] [varchar](500) NULL,
	[TargetSchema] [varchar](500) NULL,
	[TargetTable] [varchar](500) NULL,
	[Activeflag] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TECHNOLOGY_CLASSIFICATION]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TECHNOLOGY_CLASSIFICATION](
	[TECHNOLOGY_CLASS_ID] [int] NOT NULL,
	[TECHNOLOGY_CLASS_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TECHNOLOGY_CLASSIFICATION] PRIMARY KEY NONCLUSTERED 
(
	[TECHNOLOGY_CLASS_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_TECHNOLOGY_CLASS_B_TECHNOLO] UNIQUE NONCLUSTERED 
(
	[TECHNOLOGY_CLASS_NAME] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TECHNOLOGY_SOURCE]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TECHNOLOGY_SOURCE](
	[TECHNOLOGY_SOURCE_ID] [int] NOT NULL,
	[TECHNOLOGY_CLASS_ID] [int] NOT NULL,
	[GRID_ID] [int] NULL,
	[TECHNOLOGY_SOURCE_NAME] [varchar](256) NULL,
	[CARBON_INTENSITY] [decimal](12, 6) NULL,
	[YEAR] [int] NULL,
	[UNIT_CODE] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TECHNOLOGY_SOURCE] PRIMARY KEY NONCLUSTERED 
(
	[TECHNOLOGY_SOURCE_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_TECHNOLOGY_SOURCE__TECHNOLO] UNIQUE NONCLUSTERED 
(
	[TECHNOLOGY_SOURCE_NAME] ASC,
	[GRID_ID] ASC,
	[YEAR] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TECHNOLOGY_SOURCE_NEW]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TECHNOLOGY_SOURCE_NEW](
	[TECHNOLOGY_SOURCE_ID] [int] NULL,
	[TECHNOLOGY_CLASS_ID] [int] NULL,
	[TECHNOLOGY_SOURCE_NAME] [varchar](200) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TRADED_COMMODITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TRADED_COMMODITY](
	[TRADE_COMMODITY_ID] [int] NOT NULL,
	[TRADE_COMMODITY_CODE] [varchar](60) NULL,
	[TRADE_COMMODITY_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TRADED_COMMODITY] PRIMARY KEY CLUSTERED 
(
	[TRADE_COMMODITY_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_TRADED_COMMODITY_A_TRADED_C] UNIQUE NONCLUSTERED 
(
	[TRADE_COMMODITY_NAME] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_TRADED_COMMODITY_B_TRADED_C] UNIQUE NONCLUSTERED 
(
	[TRADE_COMMODITY_CODE] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UNIT_CONVERSION]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UNIT_CONVERSION](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[COMMODITY] [varchar](50) NOT NULL,
	[BASE_UOM] [varchar](50) NOT NULL,
	[TARGET_UOM] [varchar](50) NOT NULL,
	[CONVERSION] [decimal](30, 15) NULL,
	[Createdby] [varchar](256) NOT NULL,
	[createddate] [datetime] NOT NULL,
	[Modifiedby] [varchar](256) NOT NULL,
	[Modifieddate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UNIT_OF_MEASURE]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UNIT_OF_MEASURE](
	[UNIT_ID] [int] NOT NULL,
	[UNIT_CODE] [varchar](60) NULL,
	[UNIT_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_UNIT_OF_MEASURE] PRIMARY KEY CLUSTERED 
(
	[UNIT_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [AK_UNIT_OF_MEASURE_AK_UNIT_OF_] UNIQUE NONCLUSTERED 
(
	[UNIT_CODE] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[ADT_SOURCE_MAPPING_TABLE]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[ADT_SOURCE_MAPPING_TABLE](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[sheetname] [varchar](500) NULL,
	[FileName] [varchar](500) NULL,
	[TargetSchema] [varchar](500) NULL,
	[TargetTable] [varchar](500) NULL,
	[Activeflag] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_BUSINESS]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_BUSINESS](
	[BUSINESS_ID] [int] NOT NULL,
	[BUSINESS_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_BUSINESS] PRIMARY KEY CLUSTERED 
(
	[BUSINESS_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_BUSINESS_UNIT]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_BUSINESS_UNIT](
	[BUSINESS_UNIT_ID] [int] NOT NULL,
	[Activity_Entity_Name] [varchar](100) NULL,
	[Reporting_Entity_Name] [varchar](100) NULL,
	[BUSINESS_DOMAIN] [varchar](100) NULL,
	[LINE_OF_BUSINESS] [varchar](100) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
	[UpsAsHi_Performance_UnitName] [varchar](100) NULL,
	[Carbon_Region] [int] NOT NULL,
 CONSTRAINT [PK_DIM_BUSINESS_UNIT] PRIMARY KEY CLUSTERED 
(
	[BUSINESS_UNIT_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_CARBON_INTENSITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_CARBON_INTENSITY](
	[CARBON_INTENSITY_ID] [int] NULL,
	[PARAMETER_ID] [int] NULL,
	[COUNTRY_ID] [int] NULL,
	[REGION_ID] [int] NULL,
	[Technology_Source_ID] [int] NULL,
	[TRADE_commodity_ID] [int] NULL,
	[GRID_ID] [int] NULL,
	[Year] [int] NULL,
	[CARBON_INTENSITY] [decimal](12, 6) NULL,
	[UNIT_CODE] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_COUNTRY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_COUNTRY](
	[COUNTRY_ID] [int] NOT NULL,
	[REGION_ID] [int] NOT NULL,
	[COUNTRY_CODE] [varchar](256) NOT NULL,
	[COUNTRY_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_COUNTRY] PRIMARY KEY CLUSTERED 
(
	[COUNTRY_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_GRID]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_GRID](
	[GRID_ID] [int] NOT NULL,
	[REGION_NAME] [varchar](256) NULL,
	[COUNTRY_CODE] [varchar](2) NULL,
	[COUNTRY_NAME] [varchar](256) NULL,
	[Grid] [varchar](256) NULL,
	[Grid_Preferred_Name] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_GRID] PRIMARY KEY CLUSTERED 
(
	[GRID_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_INTENSITY_PARAMETER]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_INTENSITY_PARAMETER](
	[INTENSITY_PARAMETER_ID] [int] NULL,
	[PARAMETER] [varchar](200) NULL,
	[YEAR] [int] NULL,
	[Value] [decimal](12, 6) NULL,
	[UNIT_CODE] [varchar](100) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_PARAMETER]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_PARAMETER](
	[PARAMETER_ID] [int] NOT NULL,
	[PARAMETER_CODE] [varchar](100) NOT NULL,
	[PARAMETER_NAME] [varchar](100) NULL,
	[TRADE_COMMODITY_ID] [int] NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_PARAMETER] PRIMARY KEY CLUSTERED 
(
	[PARAMETER_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_PLANNING_CARBON_INTENSITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_PLANNING_CARBON_INTENSITY](
	[PLANNING_CARBON_INTENSITY_ID] [int] IDENTITY(1,1) NOT NULL,
	[Parameter_ID] [int] NULL,
	[REGION_ID] [int] NULL,
	[YEAR] [int] NULL,
	[Carbon_Intensity] [decimal](12, 6) NULL,
	[Unit_Code] [varchar](100) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_REGION]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_REGION](
	[REGION_ID] [int] NOT NULL,
	[REGION_CODE] [varchar](60) NULL,
	[REGION_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_REGION] PRIMARY KEY CLUSTERED 
(
	[REGION_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_TECHNOLOGY_CLASSIFICATION]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_TECHNOLOGY_CLASSIFICATION](
	[TECHNOLOGY_CLASS_ID] [int] NOT NULL,
	[TECHNOLOGY_CLASS_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_TECHNOLOGY_CLASSIFICATION] PRIMARY KEY CLUSTERED 
(
	[TECHNOLOGY_CLASS_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_TECHNOLOGY_SOURCE]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_TECHNOLOGY_SOURCE](
	[TECHNOLOGY_SOURCE_ID] [int] NOT NULL,
	[TECHNOLOGY_CLASS_ID] [int] NOT NULL,
	[GRID_ID] [int] NULL,
	[TECHNOLOGY_SOURCE_NAME] [varchar](256) NULL,
	[CARBON_INTENSITY] [decimal](12, 6) NULL,
	[YEAR] [int] NULL,
	[UNIT_CODE] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_TECHNOLOGY_SOURCE_ID] PRIMARY KEY CLUSTERED 
(
	[TECHNOLOGY_SOURCE_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_TECHNOLOGY_SOURCE_NEW]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_TECHNOLOGY_SOURCE_NEW](
	[TECHNOLOGY_SOURCE_ID] [int] NULL,
	[TECHNOLOGY_CLASS_ID] [int] NULL,
	[TECHNOLOGY_SOURCE_NAME] [varchar](200) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_TRADED_COMMODITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_TRADED_COMMODITY](
	[TRADE_COMMODITY_ID] [int] NOT NULL,
	[TRADE_COMMODITY_CODE] [varchar](60) NULL,
	[TRADE_COMMODITY_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_TRADED_COMMODITY] PRIMARY KEY CLUSTERED 
(
	[TRADE_COMMODITY_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_UNIT_CONVERSION]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_UNIT_CONVERSION](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[COMMODITY] [varchar](50) NOT NULL,
	[BASE_UOM] [varchar](50) NOT NULL,
	[TARGET_UOM] [varchar](50) NOT NULL,
	[CONVERSION] [decimal](30, 15) NULL,
	[Createdby] [varchar](256) NOT NULL,
	[createddate] [datetime] NOT NULL,
	[Modifiedby] [varchar](256) NOT NULL,
	[Modifieddate] [datetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[DIM_UNIT_OF_MEASURE]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[DIM_UNIT_OF_MEASURE](
	[UNIT_ID] [int] NOT NULL,
	[UNIT_CODE] [varchar](60) NULL,
	[UNIT_NAME] [varchar](256) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_DIM_UNIT_OF_MEASURE] PRIMARY KEY CLUSTERED 
(
	[UNIT_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[FACT_DEAL_BOOK]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[FACT_DEAL_BOOK](
	[DEAL_BOOK_ID] [int] IDENTITY(1,1) NOT NULL,
	[BUSINESS_UNIT_ID] [int] NOT NULL,
	[YEAR] [int] NULL,
	[PURCHASES_GA] [decimal](18, 0) NULL,
	[REVENUES_GA] [decimal](18, 0) NULL,
	[GROSS_PROFIT] [decimal](18, 0) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_FACT_DEAL_BOOK] PRIMARY KEY CLUSTERED 
(
	[DEAL_BOOK_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[FACT_DEAL_QUANTITY]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[FACT_DEAL_QUANTITY](
	[DEAL_QUANTITY_ID] [int] IDENTITY(1,1) NOT NULL,
	[BUSINESS_UNIT_ID] [int] NOT NULL,
	[REGION_ID] [int] NOT NULL,
	[COUNTRY_ID] [int] NOT NULL,
	[TRADE_COMMODITY_ID] [int] NOT NULL,
	[TRADE_DATE] [date] NOT NULL,
	[UNIT_CODE] [int] NOT NULL,
	[PARAMETER_ID] [int] NOT NULL,
	[QUANTITY] [decimal](18, 6) NULL,
	[CARBON_EMISSION] [decimal](30, 15) NULL,
	[SOURCE] [varchar](100) NULL,
	[CreatedBy] [varchar](256) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedBy] [varchar](256) NOT NULL,
	[ModifiedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_FACT_DEAL_QUANTITY] PRIMARY KEY CLUSTERED 
(
	[DEAL_QUANTITY_ID] ASC
)WITH (STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[RAW_AE_DATA_REPORT]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[RAW_AE_DATA_REPORT](
	[Version] [varchar](256) NULL,
	[Scenario] [varchar](256) NULL,
	[Year] [int] NULL,
	[Activity_Entity_Name] [varchar](256) NULL,
	[Reporting_Entity_Name] [varchar](256) NULL,
	[UpsAsHi_Performance_UnitName] [varchar](256) NULL,
	[Line_Of_Business] [varchar](256) NULL,
	[Business_Domain] [varchar](256) NULL,
	[Inland_Sales_Other] [decimal](18, 6) NULL,
	[Purchases_Other] [decimal](18, 6) NULL,
	[Inland_Sales_Volumes_NaturalGas] [decimal](18, 6) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[RAW_AE_POWER_REPORT]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[RAW_AE_POWER_REPORT](
	[Version] [varchar](256) NULL,
	[Scenario] [varchar](256) NULL,
	[Year] [int] NULL,
	[Activity_Entity_Name] [varchar](256) NULL,
	[Reporting_Entity_Name] [varchar](256) NULL,
	[UpsAsHi_Performance_UnitName] [varchar](256) NULL,
	[Line_Of_Business] [varchar](256) NULL,
	[Business_Domain] [varchar](256) NULL,
	[_3P_Renewable_Power_Supply_PPA] [decimal](18, 6) NULL,
	[_3P_Gas_Fired_Power_Supply_PPA] [decimal](18, 6) NULL,
	[_3P_Power_Supply_Market_Pool] [decimal](18, 6) NULL,
	[Renewable_Attributes_REC] [decimal](18, 6) NULL,
	[Equity_Renewable_Power_Generation] [decimal](18, 6) NULL,
	[Equity_Gas_Fired_Power_Generation] [decimal](18, 6) NULL,
	[Blue_Hydrogen_Production] [decimal](18, 6) NULL,
	[Green_Hydrogen_Production] [decimal](18, 6) NULL,
	[Grey_Hydrogen_Production] [decimal](18, 6) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[STG_AE_DATA_REPORT]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[STG_AE_DATA_REPORT](
	[Version] [varchar](256) NULL,
	[Scenario] [varchar](256) NULL,
	[Year] [int] NULL,
	[Activity_Entity_Name] [varchar](256) NULL,
	[Reporting_Entity_Name] [varchar](256) NULL,
	[UpsAsHi_Performance_UnitName] [varchar](256) NULL,
	[Line_Of_Business] [varchar](256) NULL,
	[Business_Domain] [varchar](256) NULL,
	[KPI] [varchar](256) NULL,
	[Quantity] [decimal](18, 6) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [PlanningOne].[STG_AE_POWER_REPORT]    Script Date: 4/5/2023 9:51:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [PlanningOne].[STG_AE_POWER_REPORT](
	[Version] [varchar](256) NULL,
	[Scenario] [varchar](256) NULL,
	[Year] [int] NULL,
	[Activity_Entity_Name] [varchar](256) NULL,
	[Reporting_Entity_Name] [varchar](256) NULL,
	[UpsAsHi_Performance_UnitName] [varchar](256) NULL,
	[Line_Of_Business] [varchar](256) NULL,
	[Business_Domain] [varchar](256) NULL,
	[KPI] [varchar](256) NULL,
	[Quantity] [decimal](18, 6) NULL,
	[UOM] [varchar](256) NULL
) ON [PRIMARY]
GO
ALTER TABLE [CPM].[DIM_CARBON_INTENSITY]  WITH CHECK ADD  CONSTRAINT [FK_CARB_BY_REGION] FOREIGN KEY([REGION_ID])
REFERENCES [CPM].[DIM_REGION] ([REGION_ID])
GO
ALTER TABLE [CPM].[DIM_CARBON_INTENSITY] CHECK CONSTRAINT [FK_CARB_BY_REGION]
GO
ALTER TABLE [CPM].[DIM_CARBON_INTENSITY]  WITH CHECK ADD  CONSTRAINT [FK_CARB_CARBON_IN_TRADED_C] FOREIGN KEY([TRADE_COMMODITY_ID])
REFERENCES [CPM].[DIM_TRADED_COMMODITY] ([TRADE_COMMODITY_ID])
GO
ALTER TABLE [CPM].[DIM_CARBON_INTENSITY] CHECK CONSTRAINT [FK_CARB_CARBON_IN_TRADED_C]
GO
ALTER TABLE [CPM].[DIM_CARBON_INTENSITY]  WITH CHECK ADD  CONSTRAINT [FK1_CARB_BY_REGION] FOREIGN KEY([REGION_ID])
REFERENCES [dbo].[REGION] ([REGION_ID])
GO
ALTER TABLE [CPM].[DIM_CARBON_INTENSITY] CHECK CONSTRAINT [FK1_CARB_BY_REGION]
GO
ALTER TABLE [CPM].[DIM_CARBON_INTENSITY]  WITH CHECK ADD  CONSTRAINT [FK1_CARB_CARBON_IN_TRADED_C] FOREIGN KEY([TRADE_COMMODITY_ID])
REFERENCES [dbo].[TRADED_COMMODITY] ([TRADE_COMMODITY_ID])
GO
ALTER TABLE [CPM].[DIM_CARBON_INTENSITY] CHECK CONSTRAINT [FK1_CARB_CARBON_IN_TRADED_C]
GO
ALTER TABLE [CPM].[DIM_COUNTRY]  WITH CHECK ADD FOREIGN KEY([REGION_ID])
REFERENCES [CPM].[DIM_REGION] ([REGION_ID])
GO
ALTER TABLE [CPM].[DIM_COUNTRY]  WITH CHECK ADD  CONSTRAINT [FK_COUNTRY_IS_PART_O_REGION] FOREIGN KEY([REGION_ID])
REFERENCES [CPM].[DIM_REGION] ([REGION_ID])
GO
ALTER TABLE [CPM].[DIM_COUNTRY] CHECK CONSTRAINT [FK_COUNTRY_IS_PART_O_REGION]
GO
ALTER TABLE [CPM].[FACT_DEAL_BOOK]  WITH CHECK ADD FOREIGN KEY([BUSINESS_UNIT_ID])
REFERENCES [CPM].[DIM_BUSINESS_UNIT] ([BUSINESS_UNIT_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_BOOK]  WITH NOCHECK ADD  CONSTRAINT [FK_DEAL_BOO_BU_ASSOCI_BUSINESS] FOREIGN KEY([BUSINESS_UNIT_ID])
REFERENCES [CPM].[DIM_BUSINESS_UNIT] ([BUSINESS_UNIT_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_BOOK] CHECK CONSTRAINT [FK_DEAL_BOO_BU_ASSOCI_BUSINESS]
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY]  WITH CHECK ADD FOREIGN KEY([BUSINESS_UNIT_ID])
REFERENCES [CPM].[DIM_BUSINESS_UNIT] ([BUSINESS_UNIT_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY]  WITH CHECK ADD FOREIGN KEY([COUNTRY_ID])
REFERENCES [CPM].[DIM_COUNTRY] ([COUNTRY_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY]  WITH CHECK ADD FOREIGN KEY([PARAMETER_ID])
REFERENCES [CPM].[DIM_PARAMETER] ([PARAMETER_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY]  WITH CHECK ADD FOREIGN KEY([REGION_ID])
REFERENCES [CPM].[DIM_REGION] ([REGION_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY]  WITH CHECK ADD FOREIGN KEY([TRADE_COMMODITY_ID])
REFERENCES [CPM].[DIM_TRADED_COMMODITY] ([TRADE_COMMODITY_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY]  WITH CHECK ADD  CONSTRAINT [FK_DEAL_QUA_BELONGS_T_COUNTRY] FOREIGN KEY([COUNTRY_ID])
REFERENCES [CPM].[DIM_COUNTRY] ([COUNTRY_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY] CHECK CONSTRAINT [FK_DEAL_QUA_BELONGS_T_COUNTRY]
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY]  WITH CHECK ADD  CONSTRAINT [FK_DEAL_QUA_BELONGS_T_REGION] FOREIGN KEY([REGION_ID])
REFERENCES [CPM].[DIM_REGION] ([REGION_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY] CHECK CONSTRAINT [FK_DEAL_QUA_BELONGS_T_REGION]
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY]  WITH NOCHECK ADD  CONSTRAINT [FK_DEAL_QUA_BU_ASSOCI_BUSINESS] FOREIGN KEY([BUSINESS_UNIT_ID])
REFERENCES [CPM].[DIM_BUSINESS_UNIT] ([BUSINESS_UNIT_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY] CHECK CONSTRAINT [FK_DEAL_QUA_BU_ASSOCI_BUSINESS]
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY]  WITH CHECK ADD  CONSTRAINT [FK_DEAL_QUA_COMMODITY_TRADED_C] FOREIGN KEY([TRADE_COMMODITY_ID])
REFERENCES [CPM].[DIM_TRADED_COMMODITY] ([TRADE_COMMODITY_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY] CHECK CONSTRAINT [FK_DEAL_QUA_COMMODITY_TRADED_C]
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY]  WITH CHECK ADD  CONSTRAINT [FK_DEAL_QUA_GROUPED_B_PARAMETE] FOREIGN KEY([PARAMETER_ID])
REFERENCES [CPM].[DIM_PARAMETER] ([PARAMETER_ID])
GO
ALTER TABLE [CPM].[FACT_DEAL_QUANTITY] CHECK CONSTRAINT [FK_DEAL_QUA_GROUPED_B_PARAMETE]
GO
ALTER TABLE [dbo].[CARBON_INTENSITY]  WITH CHECK ADD  CONSTRAINT [FK_CARB_BY_REGION] FOREIGN KEY([REGION_ID])
REFERENCES [dbo].[REGION] ([REGION_ID])
GO
ALTER TABLE [dbo].[CARBON_INTENSITY] CHECK CONSTRAINT [FK_CARB_BY_REGION]
GO
ALTER TABLE [dbo].[CARBON_INTENSITY]  WITH CHECK ADD  CONSTRAINT [FK_CARB_CARBON_IN_TRADED_C] FOREIGN KEY([TRADE_COMMODITY_ID])
REFERENCES [dbo].[TRADED_COMMODITY] ([TRADE_COMMODITY_ID])
GO
ALTER TABLE [dbo].[CARBON_INTENSITY] CHECK CONSTRAINT [FK_CARB_CARBON_IN_TRADED_C]
GO
ALTER TABLE [dbo].[COUNTRY]  WITH CHECK ADD  CONSTRAINT [FK_COUNTRY_IS_PART_O_REGION] FOREIGN KEY([REGION_ID])
REFERENCES [dbo].[REGION] ([REGION_ID])
GO
ALTER TABLE [dbo].[COUNTRY] CHECK CONSTRAINT [FK_COUNTRY_IS_PART_O_REGION]
GO
ALTER TABLE [dbo].[DEAL_BOOK]  WITH NOCHECK ADD  CONSTRAINT [FK_DEAL_BOO_BU_ASSOCI_BUSINESS] FOREIGN KEY([BUSINESS_UNIT_ID])
REFERENCES [dbo].[BUSINESS_UNIT] ([BUSINESS_UNIT_ID])
GO
ALTER TABLE [dbo].[DEAL_BOOK] CHECK CONSTRAINT [FK_DEAL_BOO_BU_ASSOCI_BUSINESS]
GO
ALTER TABLE [dbo].[DEAL_QUANTITY]  WITH CHECK ADD  CONSTRAINT [FK_DEAL_QUA_BELONGS_T_COUNTRY] FOREIGN KEY([COUNTRY_ID])
REFERENCES [dbo].[COUNTRY] ([COUNTRY_ID])
GO
ALTER TABLE [dbo].[DEAL_QUANTITY] CHECK CONSTRAINT [FK_DEAL_QUA_BELONGS_T_COUNTRY]
GO
ALTER TABLE [dbo].[DEAL_QUANTITY]  WITH CHECK ADD  CONSTRAINT [FK_DEAL_QUA_BELONGS_T_REGION] FOREIGN KEY([REGION_ID])
REFERENCES [dbo].[REGION] ([REGION_ID])
GO
ALTER TABLE [dbo].[DEAL_QUANTITY] CHECK CONSTRAINT [FK_DEAL_QUA_BELONGS_T_REGION]
GO
ALTER TABLE [dbo].[DEAL_QUANTITY]  WITH NOCHECK ADD  CONSTRAINT [FK_DEAL_QUA_BU_ASSOCI_BUSINESS] FOREIGN KEY([BUSINESS_UNIT_ID])
REFERENCES [dbo].[BUSINESS_UNIT] ([BUSINESS_UNIT_ID])
GO
ALTER TABLE [dbo].[DEAL_QUANTITY] NOCHECK CONSTRAINT [FK_DEAL_QUA_BU_ASSOCI_BUSINESS]
GO
ALTER TABLE [dbo].[DEAL_QUANTITY]  WITH CHECK ADD  CONSTRAINT [FK_DEAL_QUA_COMMODITY_TRADED_C] FOREIGN KEY([TRADE_COMMODITY_ID])
REFERENCES [dbo].[TRADED_COMMODITY] ([TRADE_COMMODITY_ID])
GO
ALTER TABLE [dbo].[DEAL_QUANTITY] CHECK CONSTRAINT [FK_DEAL_QUA_COMMODITY_TRADED_C]
GO
ALTER TABLE [dbo].[DEAL_QUANTITY]  WITH CHECK ADD  CONSTRAINT [FK_DEAL_QUA_GROUPED_B_PARAMETE] FOREIGN KEY([PARAMETER_ID])
REFERENCES [dbo].[PARAMETER] ([PARAMETER_ID])
GO
ALTER TABLE [dbo].[DEAL_QUANTITY] CHECK CONSTRAINT [FK_DEAL_QUA_GROUPED_B_PARAMETE]
GO
ALTER TABLE [dbo].[TECHNOLOGY_SOURCE]  WITH CHECK ADD  CONSTRAINT [FK_TECHNOLO_ASSOCIATE_COUNTRY] FOREIGN KEY([GRID_ID])
REFERENCES [dbo].[GRID] ([GRID_ID])
GO
ALTER TABLE [dbo].[TECHNOLOGY_SOURCE] CHECK CONSTRAINT [FK_TECHNOLO_ASSOCIATE_COUNTRY]
GO
ALTER TABLE [dbo].[TECHNOLOGY_SOURCE]  WITH CHECK ADD  CONSTRAINT [FK_TECHNOLO_CLASSIFIE_TECHNOLO] FOREIGN KEY([TECHNOLOGY_CLASS_ID])
REFERENCES [dbo].[TECHNOLOGY_CLASSIFICATION] ([TECHNOLOGY_CLASS_ID])
GO
ALTER TABLE [dbo].[TECHNOLOGY_SOURCE] CHECK CONSTRAINT [FK_TECHNOLO_CLASSIFIE_TECHNOLO]
GO
ALTER TABLE [PlanningOne].[DIM_COUNTRY]  WITH CHECK ADD FOREIGN KEY([REGION_ID])
REFERENCES [PlanningOne].[DIM_REGION] ([REGION_ID])
GO
ALTER TABLE [PlanningOne].[DIM_TECHNOLOGY_SOURCE]  WITH CHECK ADD FOREIGN KEY([GRID_ID])
REFERENCES [PlanningOne].[DIM_GRID] ([GRID_ID])
GO
ALTER TABLE [PlanningOne].[DIM_TECHNOLOGY_SOURCE]  WITH CHECK ADD FOREIGN KEY([TECHNOLOGY_CLASS_ID])
REFERENCES [PlanningOne].[DIM_TECHNOLOGY_CLASSIFICATION] ([TECHNOLOGY_CLASS_ID])
GO
ALTER TABLE [PlanningOne].[FACT_DEAL_BOOK]  WITH CHECK ADD FOREIGN KEY([BUSINESS_UNIT_ID])
REFERENCES [PlanningOne].[DIM_BUSINESS_UNIT] ([BUSINESS_UNIT_ID])
GO
ALTER TABLE [PlanningOne].[FACT_DEAL_QUANTITY]  WITH CHECK ADD FOREIGN KEY([BUSINESS_UNIT_ID])
REFERENCES [PlanningOne].[DIM_BUSINESS_UNIT] ([BUSINESS_UNIT_ID])
GO
ALTER TABLE [PlanningOne].[FACT_DEAL_QUANTITY]  WITH CHECK ADD FOREIGN KEY([COUNTRY_ID])
REFERENCES [PlanningOne].[DIM_COUNTRY] ([COUNTRY_ID])
GO
ALTER TABLE [PlanningOne].[FACT_DEAL_QUANTITY]  WITH CHECK ADD FOREIGN KEY([PARAMETER_ID])
REFERENCES [PlanningOne].[DIM_PARAMETER] ([PARAMETER_ID])
GO
ALTER TABLE [PlanningOne].[FACT_DEAL_QUANTITY]  WITH CHECK ADD FOREIGN KEY([REGION_ID])
REFERENCES [PlanningOne].[DIM_REGION] ([REGION_ID])
GO
ALTER TABLE [PlanningOne].[FACT_DEAL_QUANTITY]  WITH CHECK ADD FOREIGN KEY([TRADE_COMMODITY_ID])
REFERENCES [PlanningOne].[DIM_TRADED_COMMODITY] ([TRADE_COMMODITY_ID])
GO
ALTER DATABASE [cpm-db] SET  READ_WRITE 
GO
