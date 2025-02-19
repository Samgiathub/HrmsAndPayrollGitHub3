CREATE TABLE [dbo].[T0200_Salary_Posting_Detail] (
    [Sal_Pos_DID]   NUMERIC (18)    IDENTITY (1, 1) NOT NULL,
    [Sal_Pos_MID]   NUMERIC (18)    NOT NULL,
    [Cmp_ID]        NUMERIC (18)    NOT NULL,
    [Pos_Key]       INT             NULL,
    [GL_AccNo]      NVARCHAR (50)   NULL,
    [GL_Name]       NVARCHAR (50)   NULL,
    [Asset_Name]    NVARCHAR (50)   NULL,
    [Total_Amount]  NUMERIC (16, 2) NULL,
    [Tax_Code]      NVARCHAR (50)   NULL,
    [Cost_Center]   NVARCHAR (50)   NULL,
    [Profit_Center] NVARCHAR (50)   NULL,
    [Plant_Name]    NVARCHAR (50)   NULL,
    [Req_Status_D]  INT             NULL,
    [Login_ID]      NUMERIC (18)    NULL,
    [System_Date]   DATETIME        NULL,
    CONSTRAINT [PK_T0200_Salary_Posting_Detail] PRIMARY KEY CLUSTERED ([Sal_Pos_DID] ASC) WITH (FILLFACTOR = 95)
);

