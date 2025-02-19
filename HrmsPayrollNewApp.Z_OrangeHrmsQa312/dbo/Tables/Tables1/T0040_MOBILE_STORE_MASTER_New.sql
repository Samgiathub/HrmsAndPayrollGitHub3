CREATE TABLE [dbo].[T0040_MOBILE_STORE_MASTER_New] (
    [Store_ID]               NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [Cmp_Id]                 NUMERIC (18)  NULL,
    [Emp_Code]               VARCHAR (100) NULL,
    [Current_Outlet_Mapping] VARCHAR (200) NULL,
    [Store_Code]             VARCHAR (50)  NULL,
    [Dealer_Code]            VARCHAR (50)  NULL,
    [KRO_Type]               VARCHAR (50)  NULL,
    [RDS_Name]               VARCHAR (100) NULL,
    [ASM_Name]               VARCHAR (100) NULL,
    [ZSM_Name]               VARCHAR (100) NULL,
    [System_Date]            DATETIME      NULL,
    [Login_ID]               NUMERIC (18)  NULL,
    [Is_Active]              TINYINT       NULL,
    [Emp_ID]                 NUMERIC (18)  NULL,
    PRIMARY KEY CLUSTERED ([Store_ID] ASC) WITH (FILLFACTOR = 95)
);

